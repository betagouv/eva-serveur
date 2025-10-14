class CampagneCreateur
  NOM_CAMPAGNE_PAR_DEFAUT = "Diagnostic des risques"

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
    # Convertit le nom de l'OPCO en format slug
    opco_slug = @structure.opco.nom
                          .unicode_normalize(:nfkd)
                          .encode("ASCII", replace: "")
                          .downcase
                          .gsub(/[^a-z0-9\s-]/, "")
                          .gsub(/\s+/, "")

    "eva-entreprise-#{opco_slug}"
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
