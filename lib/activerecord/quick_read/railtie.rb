module ActiveRecord
  module QuickRead
    class Railtie < Rails::Railtie
      config.after_initialize do
        QuickRead.define_lite_structs
      rescue => e
        ActiveRecord::Base.logger.debug("QuickRead") { "Failed to define lite structs #{e.message}" }
      end
    end
  end
end
