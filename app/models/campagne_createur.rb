class CampagneCreateur
  NOM_CAMPAGNE_PAR_DEFAUT = "Diagnostic des risques"
  NOM_CAMPAGNE_GENERIQUE = "Diagnostic standard evapro"
  NOM_TECHNIQUE_GENERIQUE = "eva-entreprise"

  def initialize(structure, compte)
    @structure = structure
    @compte = compte
  end

  def cree_campagne_opco!
    return unless doit_creer_campagne?

    if opco_financeur?
      cree_campagnes_opco_financeur
    else
      cree_campagne_generique(NOM_TECHNIQUE_GENERIQUE)
    end
  end

  private

  def doit_creer_campagne?
    @structure.is_a?(StructureLocale) &&
      @structure.eva_entreprises? &&
      @structure.opcos.any?
  end

  def cree_campagnes_opco_financeur
    parcours_types = ParcoursType.pour_opco(premier_opco_financeur)
    return if parcours_types.empty?

    parcours_types.each do |parcours_type|
      libelle = libelle_campagne_avec_parcours(parcours_type)
      cree_campagne(parcours_type, libelle: libelle)
    end
  end

  def opco_financeur?
    premier_opco_financeur&.financeur? || false
  end

  # Retourne l'OPCO financeur s'il existe (il ne devrait y en avoir qu'un seul),
  # sinon retourne nil.
  def premier_opco_financeur
    @premier_opco_financeur ||= @structure.opco_financeur
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

  def cree_campagne_generique(nom_technique)
    parcours_type = ParcoursType.find_evapro_generique!
    cree_campagne(parcours_type, libelle: NOM_CAMPAGNE_GENERIQUE)
  end

  def libelle_campagne
    "#{NOM_CAMPAGNE_PAR_DEFAUT} : #{@structure.nom}"
  end

  def libelle_campagne_avec_parcours(parcours_type)
    "#{NOM_CAMPAGNE_PAR_DEFAUT} : #{@structure.nom} - #{parcours_type.libelle}"
  end
end
