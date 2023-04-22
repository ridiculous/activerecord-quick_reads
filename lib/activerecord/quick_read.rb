# frozen_string_literal: true
require "active_record"

require_relative "quick_read/version"
require_relative "quick_read/railtie" if defined?(Rails)

module ActiveRecord
  module QuickRead
    # Defines a "Lite" class for the current model, in the same namespace, with it's columns defined as attributes
    # Instances of the class are returned when calling #quick_read or #quick_reads on the models relation
    # The class is optimized for faster read times, by using less memory and skipping AR initialization
    # When the subject is asked to save or update, it'll gracefully upgrade to a **full working version**
    # It does this by hooking into method missing and delegating to the (lazily loaded) underlying model

    # Initialize the Lite models to be returned when using #quick_reads or called directly with #quick_build
    #
    # @param [ActiveRecord::Base] model - class to get Lite functionality
    def self.extended(model)
      super
      return if !model.table_name || model.abstract_class

      QuickRead.define_lite_struct(model)
    end

    def self.models
      @models ||= []
    end

    def self.define_lite_structs
      return if QuickRead.models.empty?

      ActiveRecord::Base.logger.debug("QuickRead") { "Defining #{QuickRead.models.size} quick models" }
      time = Benchmark.realtime do
        while model = models.pop
          define_lite_struct(model)
        end
      end
      ActiveRecord::Base.logger.debug("QuickRead") { "Defining quick models took #{time.round(4)}s" }
    end

    def self.define_lite_struct(model)
      model.const_set(:Lite, Struct.new(*model.column_names.map(&:to_sym)) { include(LiteBase) })
    end

    #
    # !!! Extension for the model class
    #

    # This would be used when extended onto the ApplicationRecord, which many models inherit from
    # Add the model to the queue to be run after initialization, since the models aren't fully defined yet
    # wait until connections are available, after rails init
    def inherited(model)
      QuickRead.models << model
      super
    end

    def quick_build(attrs = {})
      klass = const_get(:Lite)
      klass.new(*attrs.symbolize_keys!.values_at(*klass.members))
    end

    def quick_reads
      connection.select_all(current_scope.to_sql).map { |attrs| quick_build(attrs) }
    end

    def quick_read
      current_scope.limit(1).quick_reads.first
    end

    # Instantiate a new ActiveRecord object from a plain hash, marked as persisted, no changes, typecast
    # @param [Hash] attributes
    # @return ApplicationRecord subclass
    def from_hash(attributes)
      allocate.init_with_attributes(attributes_builder.build_from_database(attributes.stringify_keys!))
    end

    module LiteBase
      def method_missing(name, *args, &block)
        return super unless subject.respond_to?(name)

        subject.send(name, *args, &block)
      end

      def respond_to_missing?(*args)
        subject.respond_to?(*args) || super
      end

      def subject
        @subject ||= model.from_hash(to_h)
      end

      # Since the struct that includes this module is defined within the model's namespace
      def model
        self.class.module_parent
      end
    end
  end
end
