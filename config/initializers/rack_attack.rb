# frozen_string_literal: true

# Configuration de Rack::Attack pour bloquer les attaques de bots
# et autres requêtes malveillantes

class Rack::Attack
  # Désactivé en test : un run de specs feature/system enchaîne des
  # centaines de requêtes depuis la même IP, ce qui déclencherait les
  # throttles ci-dessous indépendamment du comportement testé.
  self.enabled = !Rails.env.test?

  # Configuration du cache (utilise Redis si disponible, sinon le cache Rails)
  if ENV['REDIS_URL'].present?
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])
  else
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  # Ne jamais throttler/bloquer le healthcheck de la plateforme (Scalingo)
  safelist('allow healthcheck') do |req|
    req.path.start_with?('/health_check')
  end

  # Bloquer les requêtes avec des extensions suspectes
  # Ces extensions sont souvent utilisées par des bots pour scanner les applications
  # Extensions bloquées: .php, .rst, .jsp, .zul, .htm, .action, .asp, .aspx
  blocklist('block bot attempts with suspicious extensions') do |req|
    # Liste des extensions suspectes à bloquer
    suspicious_extensions = %w[php rst jsp zul htm action asp aspx]

    # Vérifier si le path se termine par une extension suspecte
    suspicious_extensions.any? do |ext|
      req.path.match?(%r{\.#{ext}(?:\?|$)})
    end
  end

  # Bloque les scans de chemins WordPress / Exchange-OWA inexistants sur
  # notre appli (ex. /wp-admin, /wp-content, /wordpress, /owa, /autodiscover).
  # Repris du filtre équivalent dans config/initializers/rollbar.rb, qui ne
  # faisait qu'ignorer le rapport d'erreur sans empêcher la requête de
  # s'exécuter ; ici on bloque avant même que Rails ne la voie.
  blocklist('block wordpress/exchange bot scan paths') do |req|
    req.path.match?(%r{\A/(wp(?:-(?:admin|includes|content|login|json))?|wordpress|owa|ecp|autodiscover)(?:/|\z|\?)}i)
  end

  # Bloque les chemins d'icônes DSFR forgés. La seule route légitime pour ces
  # fichiers est /dsfr/icons/... (référencée en relatif par public/dsfr/*.css) ;
  # /assets/icons/... et /icons/... ne sont servis nulle part dans l'appli.
  # Un scan du 10/09/2026 a tenté ~970 requêtes de ce type en moins d'une
  # seconde depuis une seule IP, ce qui a saturé un worker Puma.
  blocklist('block forged dsfr icon paths') do |req|
    req.path.match?(%r{\A/(assets/icons|icons)/})
  end

  # Limite le nombre de requêtes par IP pour éviter qu'une rafale (scan,
  # bot, exploit) ne sature les workers Puma, quel que soit le chemin visé.
  # Fenêtre courte : coupe une rafale de type "scan" en quelques requêtes.
  throttle('rafale par ip', limit: 100, period: 10.seconds) do |req|
    req.ip
  end

  # Fenêtre longue : attrape un scan plus lent/étalé qui resterait sous le
  # seuil de la fenêtre courte.
  throttle('requetes par ip', limit: 600, period: 5.minutes) do |req|
    req.ip
  end

  # Log des requêtes bloquées/throttlées (pour le debugging et le monitoring)
  ActiveSupport::Notifications.subscribe('rack.attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    match_type = req.env['rack.attack.match_type']
    if match_type == :blocklist
      Rails.logger.warn "[Rack::Attack] Requête bloquée: #{req.ip} - #{req.path} - User-Agent: #{req.user_agent}"
    elsif match_type == :throttle
      Rails.logger.warn "[Rack::Attack] Requête throttlée: #{req.ip} - #{req.path} - User-Agent: #{req.user_agent}"
    end
  end
end

