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

    def recupere_donnees_etablissement(siret)
      return nil if siret.blank?

      url = "#{BASE_URL}/siret/#{siret}"
      reponse = Typhoeus.get(url, headers: headers)

      return nil unless reponse.success?

      donnees = JSON.parse(reponse.body)
      etablissement = donnees["etablissement"]
      return nil unless etablissement.present?

      periode = periode_actuelle(etablissement)
      return nil unless periode

      {
        code_naf: periode["activitePrincipale"],
        idcc: extrait_idcc(periode["conventionCollective"])
      }
    rescue JSON::ParserError, StandardError => e
      Rails.logger.error("Erreur lors de la récupération des données SIRET #{siret}: #{e.message}")
      nil
    end

    private

    def headers
      token = ENV["SIRENE_API_TOKEN"] || ""
      {
        "Authorization" => "Bearer #{token}",
        "Accept" => "application/json"
      }
    end

    def periode_actuelle(etablissement)
      periodes = etablissement["periodesEtablissement"] || []
      periodes.find { |p| p["dateFin"] == nil } || periodes.last
    end

    def extrait_idcc(convention_collective)
      return nil if convention_collective.blank?

      # Format attendu: "IDCC 8432" ou "8432"
      idcc = convention_collective.to_s.strip
      match = idcc.match(/\d+/)
      match ? match.to_s : nil
    end
  end
end
