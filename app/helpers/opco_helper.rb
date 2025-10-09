module OpcoHelper
  def badge_financeur(opco)
    render BadgeComponent.new(
      contenu: opco.financeur? ? "Oui" : "Non",
      class_couleur: opco.financeur? ? "fr-badge--green-emeraude" : "fr-badge--grey-950",
      display_icon: false,
      taille: "sm"
    )
  end
end
