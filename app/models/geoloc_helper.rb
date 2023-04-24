# frozen_string_literal: true

class GeolocHelper
  class << self
    def cherche_region(code_postal)
      return if code_postal.nil?

      begin
        reponse = RestClient.get("https://geo.api.gouv.fr/departements/#{departement(code_postal)}")
        code_region = JSON.parse(reponse)['codeRegion']
        reponse = RestClient.get("https://geo.api.gouv.fr/regions/#{code_region}")
        JSON.parse(reponse)['nom']
      rescue RestClient::NotFound
        Rails.logger.warn "Region introuvable pour le code postal #{code_postal}"
        nil
      end
    end

    def departement(code_postal)
      departement = code_postal.match(/^97|^98/) ? code_postal[0, 3] : code_postal[0, 2]
      departement = '2A' if departement == '20'
      departement
    end
  end
end
