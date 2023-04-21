# frozen_string_literal: true

class GeolocHelper
  class << self
    def cherche_region(code_postal)
      departement = code_postal.match(/^97|^98/) ? code_postal[0, 3] : code_postal[0, 2]
      departement = '2A' if departement == '20'
      begin
        reponse = RestClient.get("https://geo.api.gouv.fr/departements/#{departement}")
        code_region = JSON.parse(reponse)['codeRegion']
        reponse = RestClient.get("https://geo.api.gouv.fr/regions/#{code_region}")
        JSON.parse(reponse)['nom']
      rescue RestClient::NotFound
        Rails.logger.warn "Region introuvable pour le code postal #{code_postal}"
      end
    end
  end
end
