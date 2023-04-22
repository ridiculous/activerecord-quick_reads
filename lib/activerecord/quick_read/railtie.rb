module ActiveRecord
  module QuickRead
    class Railtie < Rails::Railtie
      config.after_initialize do
        QuickRead.define_lite_structs
      end
    end
  end
end
