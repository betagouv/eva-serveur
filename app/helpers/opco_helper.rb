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
    structure.opco&.nom || "Aucun OPCO rattaché"
  end
end
