class VerificateurSiret
  def initialize(structure)
    @structure = structure
  end

  def verifie_et_met_a_jour
    return false if @structure.siret.blank?

    client = Sirene::Client.new
    siret_valide = client.verifie_siret(@structure.siret)

    if siret_valide
      met_a_jour_statut_valide(client)
    else
      met_a_jour_statut_invalide
    end

    siret_valide
  end

  private

  def met_a_jour_statut_valide(client)
    @structure.statut_siret = true
    @structure.date_verification_siret = Time.current
    recupere_et_met_a_jour_donnees_etablissement(client)
  end

  def met_a_jour_statut_invalide
    @structure.statut_siret = false
    @structure.date_verification_siret = nil
  end

  def recupere_et_met_a_jour_donnees_etablissement(client)
    donnees = client.recupere_donnees_etablissement(@structure.siret)
    if donnees
      verifie_donnees_completes(donnees)
      @structure.code_naf = donnees[:code_naf]
      @structure.idcc = donnees[:idcc]
    else
      raise "Impossible de récupérer les données de l'établissement depuis l'API SIRENE"
    end
  end

  def verifie_donnees_completes(donnees)
    return unless donnees[:code_naf].blank? || donnees[:idcc].blank?

    message = "Données incomplètes de l'API SIRENE : " \
              "code_naf=#{donnees[:code_naf]}, idcc=#{donnees[:idcc]}"
    raise message
  end
end
