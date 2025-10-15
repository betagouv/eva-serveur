class CampagneCreateur
  NOM_CAMPAGNE_PAR_DEFAUT = "Diagnostic des risques"
  NOM_TECHNIQUE_GENERIQUE = "eva-entreprise"

  def initialize(structure, compte)
    @structure = structure
    @compte = compte
  end

  def cree_campagne_opco!
    return unless doit_creer_campagne?

    parcours_type = trouve_parcours_type
    return unless parcours_type

    cree_campagne(parcours_type)
  end

  private

  def doit_creer_campagne?
    @structure.is_a?(StructureLocale) &&
      @structure.eva_entreprises? &&
      @structure.opco.present?
  end

  def trouve_parcours_type
    nom_technique = genere_nom_technique_parcours
    ParcoursType.find_by!(nom_technique: nom_technique)
  end

  def genere_nom_technique_parcours
    return NOM_TECHNIQUE_GENERIQUE unless opco_financeur?

    "#{NOM_TECHNIQUE_GENERIQUE}-#{slugifie_nom_opco}"
  end

  def opco_financeur?
    @structure.opco.financeur?
  end

  def slugifie_nom_opco
    @structure.opco.nom
              .unicode_normalize(:nfkd)
              .encode("ASCII", replace: "")
              .downcase
              .gsub(/[^a-z0-9\s-]/, "")
              .gsub(/\s+/, "")
  end

  def cree_campagne(parcours_type)
    campagne = Campagne.new(
      libelle: libelle_campagne,
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
end
