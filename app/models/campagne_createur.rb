class CampagneCreateur
  NOM_CAMPAGNE_PAR_DEFAUT = "Diagnostic des risques"

  def initialize(structure, compte)
    @structure = structure
    @compte = compte
  end

  def cree_campagne_opco!
    return unless doit_creer_campagne?

    cree_campagnes_opco_financeur
  end

  private

  def doit_creer_campagne?
    @structure.is_a?(StructureLocale) &&
      @structure.evapro? &&
      @structure.opco.present?
  end

  def cree_campagnes_opco_financeur
    parcours_types = premier_opco_financeur.parcours_types
    return if parcours_types.empty?

    parcours_types.each do |parcours_type|
      libelle = libelle_campagne_avec_parcours(parcours_type)
      cree_campagne(parcours_type, libelle: libelle)
    end
  end

  # Retourne l'OPCO financeur s'il existe (il ne devrait y en avoir qu'un seul),
  # sinon retourne nil.
  def premier_opco_financeur
    @premier_opco_financeur ||= @structure.opco
  end

  def cree_campagne(parcours_type, libelle: libelle_campagne)
    campagne = Campagne.new(
      libelle: libelle,
      compte: @compte,
      parcours_type: parcours_type,
      type_programme: parcours_type.type_de_programme
    )

    campagne.save!
    campagne
  end

  def libelle_campagne
    "#{NOM_CAMPAGNE_PAR_DEFAUT} : #{@structure.nom}"
  end

  def libelle_campagne_avec_parcours(parcours_type)
    "#{NOM_CAMPAGNE_PAR_DEFAUT} : #{@structure.nom} - #{parcours_type.libelle}"
  end
end
