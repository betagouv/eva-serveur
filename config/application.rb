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
require 'dsfr/components'
require 'dsfr/assets'
require './lib/custom_exceptions_app_wrapper'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EvaServeur
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    # Conserve l'ancien ordre des callbacks after_commit (pré-7.1). Avec le
    # nouvel ordre, quand Structure et Compte sont créés dans la même
    # transaction (ex. inscription/structures_controller.rb), le after_commit
    # confirmable de Devise se déclenche en double, envoyant deux emails de
    # confirmation.
    #
    # Investigué en détail : la cause n'est pas Comptes::EnvoieEmails, c'est
    # l'ordonnancement Rails des after_commit sur plusieurs enregistrements
    # committés ensemble (Structure + Compte + Invitation). Remplacer le
    # `update` par `update_column` dans Comptes::EnvoieEmails#after_commit
    # (pour éviter le second save) a été tenté et rend le bug PIRE : ce
    # second save/commit fait justement partie de ce qui « vide » l'état de
    # callback transactionnel du compte avant le commit groupé qui suit. Ne
    # pas toucher à Comptes::EnvoieEmails pour ce problème, et ne pas retirer
    # ce flag sans revalider spec/mailers/structure_mailer_spec.rb et
    # spec/jobs/relance_utilisateur_pour_non_activation_job_spec.rb.
    config.active_record.run_after_transaction_callbacks_in_order_defined = false
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
    config.middleware.use Rack::Attack
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

    # La configuration suivante est necessaire pour que image_tag puisse afficher des svg issuent d'active storage
    image_svg = ["image/svg+xml"]
    config.active_storage.content_types_to_serve_as_binary -= image_svg
    config.active_storage.variable_content_types += image_svg
    config.active_storage.web_image_content_types += image_svg

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.autoload_lib(ignore: %w(assets tasks generateur_aleatoire.rb importeur_telephone.rb google_drive_storage.rb custom_exceptions_app_wrapper.rb importeur_commentaires.rb rake_logger.rb))

    Rails.autoloaders.main.ignore(Rails.root.join('app/controllers/active_admin/**/*'))
    config.i18n.available_locales = [:fr]
    config.i18n.default_locale = :fr

    config.middleware.use I18n::JS::Middleware

    ::ActionView::Base.field_error_proc = Formtastic::Helpers::FormHelper.formtastic_field_error_proc

    config.to_prepare do
      Devise::Mailer.helper :application
      Devise::Mailer.layout "mailer"
    end
  end
end
