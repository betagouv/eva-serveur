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
    req.path.match?(%r{\A/(wp(?:-(?:admin|includes|content|login|json))?|wordpress|owa|ecp|autodiscover|blog)(?:/|\z|\?)}i)
  end

  # Bloque les chemins d'icônes DSFR forgés. La seule route légitime pour ces
  # fichiers est /dsfr/icons/... (référencée en relatif par public/dsfr/*.css) ;
  # /assets/icons/... et /icons/... ne sont servis nulle part dans l'appli.
  # Un scan du 10/09/2026 a tenté ~970 requêtes de ce type en moins d'une
  # seconde depuis une seule IP, ce qui a saturé un worker Puma.
  blocklist('block forged dsfr icon paths') do |req|
    req.path.match?(%r{\A/(assets/icons|icons)/})
  end

  THROTTLE_PAR_SESSION_PATHS =
    %r{\A/api/(evenements|evaluations/[^/]+/collections_evenements)\z}.freeze

  # Le routeur accepte aussi /admin/login.json et /admin/login/
  CHEMIN_CONNEXION = %r{\A/admin/login(\.[^/]*)?/?\z}.freeze
  LIMITE_CONNEXIONS_PAR_EMAIL = 10
  PERIODE_CONNEXIONS_PAR_EMAIL = 10.minutes
  LIMITE_CONNEXIONS_PAR_IP = 30
  PERIODE_CONNEXIONS_PAR_IP = 5.minutes
  THROTTLES_CONNEXION = [ 'connexions par email', 'connexions par ip' ].freeze

  def self.corps_json(req)
    body = req.body.read
    req.body.rewind
    return nil if body.blank?

    json = JSON.parse(body)
    json if json.is_a?(Hash)
  rescue StandardError
    nil
  end

  def self.session_id_depuis_le_corps(req)
    json = corps_json(req)
    return nil if json.nil?

    json['session_id'] || json.dig('evenements', 0, 'session_id')
  rescue StandardError
    nil
  end

  def self.connexion?(req)
    req.post? && req.path.match?(CHEMIN_CONNEXION)
  end

  # Normalisé comme le fait Devise (casse et espaces) pour que les variantes
  # d'un même email partagent le même compteur.
  def self.email_de_connexion(req)
    compte = req.params['compte']
    compte = corps_json(req)&.dig('compte') unless compte.is_a?(Hash)
    return nil unless compte.is_a?(Hash)

    compte['email'].to_s.strip.downcase.presence
  rescue StandardError
    nil
  end

  # Limite le nombre de requêtes par IP pour éviter qu'une rafale (scan,
  # bot, exploit) ne sature les workers Puma, quel que soit le chemin visé.
  # Fenêtre courte : coupe une rafale de type "scan" en quelques requêtes.
  # Exclut les chemins throttlés par session_id (cf. plus haut).
  throttle('rafale par ip', limit: 100, period: 10.seconds) do |req|
    req.ip unless req.path.match?(THROTTLE_PAR_SESSION_PATHS)
  end

  # Fenêtre longue : attrape un scan plus lent/étalé qui resterait sous le
  # seuil de la fenêtre courte.
  throttle('requetes par ip', limit: 600, period: 5.minutes) do |req|
    req.ip unless req.path.match?(THROTTLE_PAR_SESSION_PATHS)
  end

  # Rafale par session : une session d'évaluation ne devrait pas envoyer
  # plus de 100 événements en 10s. Fallback sur l'IP si le session_id est
  # introuvable (corps malformé) pour ne pas perdre toute protection.
  throttle('rafale par session', limit: 100, period: 10.seconds) do |req|
    next unless req.post? && req.path.match?(THROTTLE_PAR_SESSION_PATHS)

    Rack::Attack.session_id_depuis_le_corps(req) || req.ip
  end

  # Tentatives de connexion : freine la recherche d'un mot de passe par essais
  # successifs. Les connexions réussies comptent aussi, Rack::Attack ne
  # connaissant pas l'issue de la requête.
  # Par email : protège un compte visé, d'où que viennent les essais.
  throttle('connexions par email', limit: LIMITE_CONNEXIONS_PAR_EMAIL,
                                   period: PERIODE_CONNEXIONS_PAR_EMAIL) do |req|
    Rack::Attack.email_de_connexion(req) if Rack::Attack.connexion?(req)
  end

  # Par IP : freine l'essai d'un même mot de passe sur beaucoup de comptes.
  # Plus large que la limite par email, car les conseillers d'une même
  # structure partagent souvent une adresse IP.
  throttle('connexions par ip', limit: LIMITE_CONNEXIONS_PAR_IP,
                                period: PERIODE_CONNEXIONS_PAR_IP) do |req|
    req.ip if Rack::Attack.connexion?(req)
  end

  # La personne bloquée à la connexion voit cette réponse dans son navigateur :
  # message en français. Les autres throttles gardent la réponse par défaut.
  reponse_throttle_par_defaut = throttled_responder
  self.throttled_responder = lambda do |req|
    unless THROTTLES_CONNEXION.include?(req.env['rack.attack.matched'])
      next reponse_throttle_par_defaut.call(req)
    end

    donnees = req.env['rack.attack.match_data']
    attente = donnees[:period] - (donnees[:epoch_time] % donnees[:period])
    [
      429,
      { 'content-type' => 'text/plain; charset=utf-8', 'retry-after' => attente.to_s },
      [ "Trop de tentatives de connexion. Veuillez réessayer dans quelques minutes.\n" ]
    ]
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

