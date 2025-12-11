class Evaluation::MesureImpactCalloutComponent < ViewComponent::Base
  def initialize(titre:, resultat:, classes: [])
    @titre = titre
    @classes = Array(classes).push(color_class(resultat), "fr-mb-0")
  end

  private

  def color_class(resultat)
    return "fr-callout--pink-macaron" if resultat == :tres_fort || resultat == :fort
    return "fr-callout--blue-cumulus" if resultat == :moyen

    "fr-callout--green-emeraude"
  end
end
