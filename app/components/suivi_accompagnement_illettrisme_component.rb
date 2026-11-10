# Tous les blocs (question, qualification, réponses) sont rendus ; le JS partagé
# avec le tableau de bord (mise_en_action.js.erb) n'en montre qu'un selon l'état.
class SuiviAccompagnementIllettrismeComponent < ViewComponent::Base
  # Sur le tableau de bord, la carte propose une personne à la fois : l'en-tête y est
  # compact avec le lien vers l'évaluation, et la réponse complète passe à la suivante.
  def initialize(evaluation:, tableau_de_bord: false)
    @evaluation = evaluation
    @tableau_de_bord = tableau_de_bord
  end

  def reponses
    return [ true, false ] unless MiseEnAction.pas_encore_actif?

    [ true, MiseEnAction::REPONSE_PAS_ENCORE, false ]
  end

  def tableau_de_bord?
    @tableau_de_bord
  end

  def classes
    [ "carte__conteneur", "suivi-accompagnement-illettrisme",
      ("suivi-accompagnement-illettrisme--tableau-de-bord" if @tableau_de_bord) ].compact.join(" ")
  end
end
