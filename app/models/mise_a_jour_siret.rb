class MiseAJourSiret
  def initialize(structure)
    @structure = structure
  end

  def verifie_et_met_a_jour
    return false if @structure.siret.blank?

    donnees_api = recupere_donnees_api
    siret_valide = verifie(donnees_api)
    met_a_jour(siret_valide, donnees_api)
    siret_valide
  end

  private

  def recupere_donnees_api
    client = Sirene::Client.new
    client.recherche(@structure.siret)
  end

  def verifie(donnees_api)
    return false if donnees_api.blank?

    siret_trouve?(donnees_api, @structure.siret)
  end

  def met_a_jour(siret_valide, donnees_api)
    if siret_valide
      @structure.statut_siret = true
      @structure.date_verification_siret = Time.current
      met_a_jour_donnees_sirene(donnees_api)
    else
      @structure.statut_siret = false
      @structure.date_verification_siret = nil
    end
  end

  def met_a_jour_donnees_sirene(donnees_api)
    return if donnees_api.blank?

    resultat = donnees_api["results"]&.first
    return if resultat.blank?

    @structure.code_naf = resultat["activite_principale"]
    @structure.idcc = resultat.dig("complements", "liste_idcc") || []
    @structure.raison_sociale = resultat["nom_raison_sociale"] || resultat["nom_complet"]
    @structure.adresse = recupere_adresse(resultat)
  end

  def recupere_adresse(resultat)
    siret_recherche = @structure.siret

    # Vérifier si c'est le siège
    return resultat.dig("siege", "adresse") if resultat.dig("siege", "siret") == siret_recherche

    # Chercher dans les établissements correspondants
    etablissement = resultat.dig("matching_etablissements")&.find do |etab|
      etab["siret"] == siret_recherche
    end

    etablissement&.dig("adresse")
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
