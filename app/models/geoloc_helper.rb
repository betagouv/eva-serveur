class GeolocHelper
  class << self
    def cherche_commune(code_postal)
      return if code_postal.nil?

      reponse = Typhoeus.get("https://geo.api.gouv.fr/communes?codePostal=#{code_postal}&fields=code,centre,region")
      unless reponse.success?
        journalise_erreur(reponse, "recherche de la commune du code postal #{code_postal}")
        return
      end

      commune = JSON.parse(reponse.body).first
      return unless commune

      coordonnees = commune.dig("centre", "coordinates")
      {
        code_commune: commune["code"],
        region: commune.dig("region", "nom")
      }
    end

    def journalise_erreur(reponse, action)
      if reponse.timed_out?
        Rails.logger.error("Erreur #{action} : API request timed out")
      elsif reponse.code.zero?
        # Could not get an HTTP response
        Rails.logger.error("Erreur #{action} : #{reponse.return_message}")
      else
        Rails.logger.error("Erreur #{action} : HTTP request failed: #{reponse.code}")
      end
    end
  end
end
