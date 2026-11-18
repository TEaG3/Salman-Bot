require_relative "boot"
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module SalmanBot
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
    config.time_zone = "UTC"
    config.active_record.schema_format = :sql
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")
        resource "/api/*", headers: :any, methods: %i[get post patch delete options], max_age: 600
      end
    end
  end
end
