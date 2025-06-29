# frozen_string_literal: true

HealthCheck.setup do |config|
  # on souhaite avoir l'url /healthcheck/all.json
  config.uri = '/healthcheck'

  # Permet de voir l'erreur en activant la variable d'environnement
  # HEALTHCHECK_DEBUG=true
  config.include_error_in_response_body = ENV.fetch('HEALTHCHECK_DEBUG', false)

  config.log_level = 'info'

  # on souhaite retourner une 503 plutôt qu'une 500
  config.http_status_for_error_text = 503
  config.http_status_for_error_object = 503

  # configurer comme vous le souhaitez
  # les check standard sont pour /healthcheck.json
  config.standard_checks = %w[database migrations]
  # les check complets sont pour /healthcheck/all.json
  config.full_checks = %w[site database migrations]

  # Envoyer le détail de l'erreur sur Slack
  config.on_failure do |checks, msg|
    url = ENV.fetch('URL_WEBHOOK_HEALTH_CHECK', nil)
    if url.present?
      message = "[#{checks}] #{msg}"
      payload = {
        text: message
      }

      require 'net/http'
      require 'uri'

      Net::HTTP.post URI(url), payload.to_json, 'Content-Type': 'application/json'
    end
  end
end
