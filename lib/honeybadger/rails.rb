require 'honeybadger'
require 'honeybadger/rails/controller_methods'
require 'honeybadger/rails/action_controller_catcher'

module Honeybadger
  module Rails
    def self.initialize
      if defined?(ActionController::Base)
        ActionController::Base.send(:include, Honeybadger::Rails::ActionControllerCatcher)
        ActionController::Base.send(:include, Honeybadger::Rails::ControllerMethods)
      end

      rails_logger = if defined?(::Rails.logger)
                       ::Rails.logger
                     elsif defined?(RAILS_DEFAULT_LOGGER)
                       RAILS_DEFAULT_LOGGER
                     end

      if defined?(::Rails.configuration) && ::Rails.configuration.respond_to?(:middleware)
        ::Rails.configuration.middleware.insert_after 'ActionController::Failsafe',
                                                      Honeybadger::Rack
        ::Rails.configuration.middleware.insert_after 'Rack::Lock',
                                                      Honeybadger::UserInformer
      end

      Honeybadger.configure(true) do |config|
        config.logger           = rails_logger
        config.environment_name = defined?(::Rails.env) && ::Rails.env || defined?(RAILS_ENV) && RAILS_ENV
        config.project_root     = defined?(::Rails.root) && ::Rails.root || defined?(RAILS_ROOT) && RAILS_ROOT
        config.framework        = defined?(::Rails.version) && "Rails: #{::Rails.version}" || defined?(::Rails::VERSION::STRING) && "Rails: #{::Rails::VERSION::STRING}"
      end
    end
  end
end

Honeybadger::Rails.initialize
