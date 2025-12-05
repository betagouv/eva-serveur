class RechercheStructureParSiret
  def initialize(compte, siret)
    @compte = compte
    @siret = siret
  end

  def call
    return @compte if @siret.blank?

    # Cherche une structure existante avec le SIRET
    structure_existante = cherche_structure_avec_siret(@siret)

    if structure_existante.present?
      @compte.structure = structure_existante
    else
      # Crée une structure temporaire pré-remplie via l'API Sirene
      structure_temporaire = cree_structure_temporaire
      @compte.structure = structure_temporaire if structure_temporaire.present?
    end

    @compte
  end

  private

  def cherche_structure_avec_siret(siret)
    Structure.find_by(siret: siret)
  end

  def cree_structure_temporaire
    structure = StructureLocale.new(
      siret: @siret,
      usage: "Eva: bénéficiaires"
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
