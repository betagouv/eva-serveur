class RechercheStructureParSiret
  def initialize(siret)
    @siret = siret
  end

  def call
    return nil if @siret.blank?

    structure_existante = cherche_structure_avec_siret(@siret)

    return structure_existante if structure_existante.present?

    structure_temporaire = cree_structure_temporaire_via_api_sirene
  end

  private

  def cherche_structure_avec_siret(siret)
    Structure.find_by(siret: siret)
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
    structure.code_postal = extrait_code_postal(structure.adresse) || StructureLocale::TYPE_NON_COMMUNIQUE

    structure
  end

  def extrait_code_postal(adresse)
    return nil if adresse.blank?

    # Extrait le code postal de l'adresse (format : 5 chiffres)
    match = adresse.match(/\b(\d{5})\b/)
    match ? match[1] : nil
  end
end
