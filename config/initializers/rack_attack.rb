# frozen_string_literal: true

# Configuration de Rack::Attack pour bloquer les attaques de bots
# et autres requêtes malveillantes

class Rack::Attack
  # Configuration du cache (utilise Redis si disponible, sinon le cache Rails)
  if ENV['REDIS_URL'].present?
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])
  else
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  # Bloquer les requêtes avec des extensions suspectes
  # Ces extensions sont souvent utilisées par des bots pour scanner les applications
  # Extensions bloquées: .php, .rst, .jsp, .zul, .htm, .action
  blocklist('block bot attempts with suspicious extensions') do |req|
    # Liste des extensions suspectes à bloquer
    suspicious_extensions = %w[php rst jsp zul htm action]
    
    # Vérifier si le path se termine par une extension suspecte
    suspicious_extensions.any? do |ext|
      req.path.match?(%r{\.#{ext}(?:\?|$)})
    end
  end

  # Log des requêtes bloquées (pour le debugging et le monitoring)
  ActiveSupport::Notifications.subscribe('rack.attack') do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    if req.env['rack.attack.match_type'] == :blocklist
      Rails.logger.warn "[Rack::Attack] Requête bloquée: #{req.ip} - #{req.path} - User-Agent: #{req.user_agent}"
    end
  end
end

