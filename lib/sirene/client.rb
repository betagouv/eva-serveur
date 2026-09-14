module Sirene
  class Client
    class Indisponible < StandardError; end

    BASE_URL = ENV.fetch("SIRENE_API_URL")

    def recherche(siret)
      return nil if siret.blank?

      url = "#{BASE_URL}/search?q=#{siret}"
      reponse = Typhoeus.get(url, headers: headers)

      raise "réponse HTTP #{reponse.code}" unless reponse.success?

      JSON.parse(reponse.body)
    rescue StandardError => e
      raise Indisponible, e.message
    end

    private

    def headers
      {
        "Accept" => "application/json",
        "User-Agent" => "EVA-Serveur (#{ENV['HOTE_SERVEUR']})"
      }
    end
  end
end
