module Sirene
  class Client
    BASE_URL = "https://api.insee.fr/entreprises/sirene/V3.11".freeze

    def verifie_siret(siret)
      return false if siret.blank?

      url = "#{BASE_URL}/siret/#{siret}"
      reponse = Typhoeus.get(url, headers: headers)

      return false unless reponse.success?

      donnees = JSON.parse(reponse.body)
      donnees["etablissement"].present?
    rescue JSON::ParserError, StandardError => e
      Rails.logger.error("Erreur lors de la vérification SIRET #{siret}: #{e.message}")
      false
    end

    private

    def headers
      token = ENV["SIRENE_API_TOKEN"] || ""
      {
        "Authorization" => "Bearer #{token}",
        "Accept" => "application/json"
      }
    end
  end
end

