module Sirene
  class Client
    BASE_URL = ENV.fetch("SIRENE_API_URL", nil).freeze

    def verifie_siret(siret)
      return false if siret.blank?

      url = "#{BASE_URL}/search?q=#{siret}"
      reponse = Typhoeus.get(url, headers: headers)

      return false unless reponse.success?

      donnees = JSON.parse(reponse.body)
      siret_trouve?(donnees, siret)
    rescue JSON::ParserError, StandardError => e
      Rails.logger.error("Erreur lors de la vérification SIRET #{siret}: #{e.message}")
      false
    end

    private

    def headers
      {
        "Accept" => "application/json"
      }
    end

    def siret_trouve?(donnees, siret_recherche)
      return false if donnees["results"].blank?

      donnees["results"].any? do |resultat|
        # Vérifier dans le siège
        resultat.dig("siege", "siret") == siret_recherche ||
          # Vérifier dans les établissements correspondants
          resultat.dig("matching_etablissements")&.any? { |etab| etab["siret"] == siret_recherche }
      end
    end
  end
end
