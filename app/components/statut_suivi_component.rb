class StatutSuiviComponent < ViewComponent::Base
  CLASSES_COULEUR = {
    "suite_engagee" => "fr-badge--success",
    "reporte" => "fr-badge--yellow-tournesol",
    "pas_de_suite" => "fr-badge--info",
    "a_renseigner" => "fr-badge--beige-gris-galet"
  }.freeze

  def initialize(statut:)
    @statut = statut
  end

  def concerne?
    @statut != "non_concerne"
  end

  def badge
    BadgeComponent.new(contenu: I18n.t("statut_suivi.#{@statut}"),
                       class_couleur: CLASSES_COULEUR[@statut],
                       taille: "sm")
  end
end
