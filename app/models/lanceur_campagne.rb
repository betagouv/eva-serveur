class LanceurCampagne
  def initialize(campagne, compte = nil)
    @campagne = campagne
    @compte = compte
    @beneficiaire = retrouve_ou_cree_beneficiaire if @compte
  end

  def url
    base_url = URL_CLIENT
    base_url = URL_EVA_ENTREPRISES if campagne_entreprise?
    addressable_uri = "#{base_url}?code=#{@campagne.code}"
    if @beneficiaire && campagne_entreprise?
      addressable_uri += "&beneficiaire_id=#{@beneficiaire.id}"
    end
    Addressable::URI.escape(addressable_uri)
  end

  def self.url(campagne, compte = nil)
    new(campagne, compte).url
  end

  private

  def campagne_entreprise?
    @campagne.parcours_type&.diagnostic_entreprise?
  end

  def retrouve_ou_cree_beneficiaire
    Beneficiaire.where(compte: @compte).first_or_create do |beneficiaire|
      beneficiaire.nom = @compte.nom_complet
    end
  end
end
