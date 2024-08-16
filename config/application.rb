require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "jwt"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require 'view_component'
require 'view_component/storybook'
require './lib/custom_exceptions_app_wrapper'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EvaServeur
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.time_zone = 'Paris'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    config.exceptions_app = CustomExceptionsAppWrapper.new(exceptions_app: routes)
    
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.orm :active_record, foreign_key_type: :uuid
    end

    config.action_controller.asset_host = "#{ENV['PROTOCOLE_SERVEUR']}://#{ENV['HOTE_SERVEUR']}"
    config.action_mailer.asset_host = "#{ENV['PROTOCOLE_SERVEUR']}://#{ENV['HOTE_SERVEUR']}"
    Rails.application.routes.default_url_options = {
      host: ENV['HOTE_SERVEUR'],
      protocol: ENV['PROTOCOLE_SERVEUR']
    }

    config.active_job.queue_adapter = :sidekiq
    config.active_storage.track_variants = false

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    Rails.autoloaders.main.ignore(Rails.root.join('app/controllers/active_admin/**/*'))
    config.i18n.available_locales = [:fr]
    config.i18n.default_locale = :fr
    config.middleware.use I18n::JS::Middleware

    config.view_component_storybook.stories_path = Rails.root.join("spec/components/stories")

    ::ActionView::Base.field_error_proc = Formtastic::Helpers::FormHelper.formtastic_field_error_proc

    config.to_prepare do
      Devise::Mailer.helper :application
      Devise::Mailer.layout "mailer"
    end
  end
end
