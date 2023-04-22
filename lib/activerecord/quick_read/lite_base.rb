module ActiveRecord
  module QuickRead
    module LiteBase
      def method_missing(name, *args, &block)
        return super unless _ar_instance.respond_to?(name)

        _ar_instance.send(name, *args, &block)
      end

      def respond_to_missing?(*args)
        _ar_instance.respond_to?(*args) || super
      end

      def reload(*)
        source = @_ar_instance&.reload
        source ||= _ar_model.unscoped.where(id: id).quick_read
        return false unless source

        members.each { |attr| send(:"#{attr}=", source.send(attr)) }
        self
      end

      # Private

      def _ar_instance
        @_ar_instance ||= _ar_model.from_hash(to_h)
      end

      # Since the struct that includes this module is defined within the model's namespace
      def _ar_model
        self.class.module_parent
      end
    end
  end
end
