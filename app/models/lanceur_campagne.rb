class LanceurCampagne
  def initialize(campagne, compte)
    @campagne = campagne
    @compte = compte
  end

  def url
    addressable_uri = if @campagne.evapro?
      beneficiaire = retrouve_ou_cree_beneficiaire(@compte)
      "#{URL_EVA_ENTREPRISES}?code=#{@campagne.code}&beneficiaire_id=#{beneficiaire.id}"
    else
      "#{URL_CLIENT}?code=#{@campagne.code}"
    end
    Addressable::URI.escape(addressable_uri)
  end

  def self.url(campagne, compte = nil)
    new(campagne, compte).url
  end

  private

  def retrouve_ou_cree_beneficiaire(compte)
    Beneficiaire.where(compte: compte).first_or_create do |beneficiaire|
      beneficiaire.nom = compte.nom_complet
    end
  end
end
