require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EpdSimulator
  class Application < Rails::Application
     require 'sinapse_mqtt_client_singleton'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    # Configure adapters for Active Jobs
    config.active_job.queue_adapter = :sucker_punch

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # MQTT configuration
    config.installation_name = "SINAPSE_SIMULATOR"
    config.ap = "700190" # AP used for simulations
    config.subscription_root = Rails.application.config.installation_name + "/" + config.ap + "/ACT/" 
    config.publish_measurements_topic = Rails.application.config.installation_name + "/EPD/MEASUREMENTS"
    config.publish_periodic_topic = Rails.application.config.installation_name + "/EPD/PERIODIC" 
    config.publish_alerts_topic = Rails.application.config.installation_name + "/EPD/ALERTS"

    config.debug_topic = "SINAPSE/IOT/DEBUG"


    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
