# Configuration OpenSSL pour résoudre les problèmes de vérification CRL
# avec OpenSSL 3.6.0+
#
# OpenSSL 3.6.0+ peut échouer avec "certificate verify failed (unable to get certificate CRL)"
# C'est un problème connu lié à un changement dans OpenSSL 3.6.0
#
# Ça pourrait être du à l'activiation de la vérification CRL par défaut,
# et que certains certificats ne publient pas de CRL accessible.
#
# Ça pourrait aussi être liés au bugs suivants :
# - https://github.com/ruby/openssl/issues/822
# - https://github.com/openssl/openssl/issues/26039
#
# Solution temporaire: Désactiver la vérification SSL en développement/test uniquement
# EN PRODUCTION: Les certificats des API doivent être corrigés côté serveur

if Rails.env.development? || Rails.env.test?
  require 'net/http'
  require 'openssl'

  # Patch 1: Net::HTTP#use_ssl=
  module Net
    class HTTP
      alias_method :original_use_ssl=, :use_ssl=

      def use_ssl=(flag)
        self.original_use_ssl = flag
        # Désactiver complètement la vérification SSL en développement
        @verify_mode = OpenSSL::SSL::VERIFY_NONE if flag
      end
    end
  end

  # Patch 2: Net::HTTP.start pour les appels directs avec block
  # Note: Simplifié - on laisse Net::HTTP gérer les paramètres,
  # on intervient juste après la création
  class << Net::HTTP
    alias_method :original_start, :start

    def start(*args, &block)
      original_start(*args) do |http|
        if http.use_ssl?
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        block ? block.call(http) : http
      end
    end
  end

  # Patch 3: OpenSSL::SSL::SSLContext#set_params - le plus bas niveau
  module OpenSSL
    module SSL
      class SSLContext
        alias_method :original_set_params, :set_params

        def set_params(params = {})
          original_set_params(params)
          # Forcer VERIFY_NONE en développement
          self.verify_mode = OpenSSL::SSL::VERIFY_NONE
          self
        end
      end
    end
  end

  # Afficher dans STDOUT pour que ça apparaisse dans les logs Foreman
  puts "⚠️  OpenSSL #{OpenSSL::OPENSSL_VERSION} - SSL verification DISABLED (#{Rails.env} mode)"
  puts "⚠️  This is a workaround for CRL issues with OpenSSL 3.6.0+"

  # Logger aussi pour les logs Rails
  Rails.logger.warn "OpenSSL #{OpenSSL::OPENSSL_VERSION} - SSL verification DISABLED"
end
