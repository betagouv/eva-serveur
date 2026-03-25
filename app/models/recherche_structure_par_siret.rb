# Recherche d'une structure par SIRET lors de l'embarquement.
# Priorité : 1) recherche en base EVA, 2) appel à l'API officielle uniquement si non trouvé.
class RechercheStructureParSiret
  def initialize(siret)
    @siret = normalise_siret(siret)
  end

  def call
    return nil if @siret.blank?

    structure_existante = cherche_structure_avec_siret(@siret)

    return structure_existante if structure_existante.present?

    structure_temporaire = cree_structure_temporaire_via_api_sirene
  end

  private

  def normalise_siret(siret)
    return nil if siret.blank?

    siret.to_s.gsub(/\s+/, "")
  end

  def cherche_structure_avec_siret(siret)
    Structure.avec_meme_siret_que(siret)
             .order(:id)
             .first
  end

  def cree_structure_temporaire_via_api_sirene
    structure = StructureLocale.new(
      siret: @siret,
      usage: "Eva: bénéficiaires",
      type_structure: StructureLocale::TYPE_NON_COMMUNIQUE
    )

    mise_a_jour = MiseAJourSiret.new(structure)
    mise_a_jour.verifie_et_met_a_jour
    structure.nom = structure.raison_sociale if structure.raison_sociale.present?

    structure
  end
end
