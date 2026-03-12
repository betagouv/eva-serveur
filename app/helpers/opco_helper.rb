module OpcoHelper
  def badge_financeur(opco)
    render BadgeComponent.new(
      contenu: Opco.human_attribute_name(opco.financeur?),
      class_couleur: opco.financeur? ? "fr-badge--green-emeraude" : "fr-badge--grey-950",
      display_icon: false,
      taille: "sm"
    )
  end

  def affiche_opcos(structure)
    structure.opco&.nom || "Aucun opérateur de compétences rattaché"
  end

  def suggestions_nom_parcours_type_evapro(opco)
    prefix = "#{ParcoursType::PREFIX_NOM_TECHNIQUE_EVAPRO}-#{opco.slug}"
    [prefix, "#{prefix}__nom"]
  end
end
