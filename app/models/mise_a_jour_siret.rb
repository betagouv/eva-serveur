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

    etablissement = etablissement_correspondant(donnees_api)
    return false if etablissement.blank?

    if etablissement["etat_administratif"] == "F"
      @structure.siret_ferme = true if @structure.respond_to?(:siret_ferme=)
      return false
    end

    true
  end

  def met_a_jour(siret_valide, donnees_api)
    if siret_valide
      @structure.statut_siret = true
      @structure.date_verification_siret = Time.current
      @structure.siret_ferme = false if @structure.respond_to?(:siret_ferme=)
      met_a_jour_donnees_sirene(donnees_api)
    else
      @structure.statut_siret = false
      @structure.date_verification_siret = nil
    end
  end

  def etablissement_correspondant(donnees_api)
    siret_recherche = @structure.siret
    resultat = donnees_api["results"]&.first
    return nil if resultat.blank?

    return resultat["siege"] if resultat.dig("siege", "siret") == siret_recherche

    resultat.dig("matching_etablissements")&.find { |etab| etab["siret"] == siret_recherche }
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
end
