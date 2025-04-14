# frozen_string_literal: true

class GeolocHelper
  class << self
    def cherche_region(code_postal)
      return if code_postal.nil?

      reponse = Typhoeus.get("https://geo.api.gouv.fr/departements/#{departement(code_postal)}")
      unless reponse.success?
        journalise_erreur(reponse, "recherche du département du code postal #{code_postal}")
        return
      end

      code_region = JSON.parse(reponse.body)["codeRegion"]
      cherche_nom_region(code_region)
    end

    def cherche_nom_region(code_region)
      reponse = Typhoeus.get("https://geo.api.gouv.fr/regions/#{code_region}")
      unless reponse.success?
        journalise_erreur(reponse, "recherche de la région #{code_region}")
        return
      end

      JSON.parse(reponse.body)["nom"]
    end

    def departement(code_postal)
      departement = code_postal.match(/^97|^98/) ? code_postal[0, 3] : code_postal[0, 2]
      departement = "2A" if departement == "20"
      departement
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
