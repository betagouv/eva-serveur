class VerificateurSiret
  def initialize(structure)
    @structure = structure
  end

  def verifie_et_met_a_jour
    return false if @structure.siret.blank?

    client = Sirene::Client.new
    siret_valide = client.verifie_siret(@structure.siret)

    if siret_valide
      @structure.statut_siret = true
      @structure.date_verification_siret = Time.current
    else
      @structure.statut_siret = false
      @structure.date_verification_siret = nil
    end

    siret_valide
  end
end
