module ActiveRecord
  module QuickRead
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

      def reload(*)
        source = @subject&.reload
        source ||= model.unscoped.where(id: id).select(members.join(', ')).quick_read
        return false unless source

        members.each { |attr| send(:"#{attr}=", source.send(attr)) }
        self
      end
    end
  end
end
