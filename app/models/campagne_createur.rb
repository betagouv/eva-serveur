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

    parcours_type = trouve_parcours_type
    return unless parcours_type

    cree_campagne(parcours_type)
    cree_campagne_generique(NOM_TECHNIQUE_GENERIQUE)
  end

  private

  def doit_creer_campagne?
    @structure.is_a?(StructureLocale) &&
      @structure.eva_entreprises? &&
      @structure.opcos.any?
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
    premier_opco_financeur&.financeur? || false
  end

  def slugifie_nom_opco
    premier_opco_financeur&.nom
              &.unicode_normalize(:nfkd)
              &.encode("ASCII", replace: "")
              &.downcase
              &.gsub(/[^a-z0-9\s-]/, "")
              &.gsub(/\s+/, "") || ""
  end

  def premier_opco_financeur
    @premier_opco_financeur ||= @structure.opcos.find(&:financeur?) || @structure.opcos.first
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
    parcours_type = ParcoursType.find_by!(nom_technique: nom_technique)
    cree_campagne(parcours_type, libelle: "#{NOM_CAMPAGNE_GENERIQUE}")
  end

  def libelle_campagne
    "#{NOM_CAMPAGNE_PAR_DEFAUT} : #{@structure.nom}"
  end
end
