module Sirene
  class Client
    BASE_URL = ENV.fetch("SIRENE_API_URL").freeze

    def recherche(siret)
      return nil if siret.blank?

      url = "#{BASE_URL}/search?q=#{siret}"
      reponse = Typhoeus.get(url, headers: headers)

      return nil unless reponse.success?

      JSON.parse(reponse.body)
    rescue JSON::ParserError, StandardError => e
      Rails.logger.error("Erreur lors de la recherche SIRET #{siret}: #{e.message}")
      nil
    end

    private

    def headers
      {
        "Accept" => "application/json"
      }
    end
  end
end
