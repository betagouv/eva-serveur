# Tous les blocs (question, qualification, réponses) sont rendus ; le JS partagé
# avec le tableau de bord (mise_en_action.js.erb) n'en montre qu'un selon l'état.
class SuiviAccompagnementIllettrismeComponent < ViewComponent::Base
  def initialize(evaluation:)
    @evaluation = evaluation
  end

  def reponses
    return [ true, false ] unless MiseEnAction.pas_encore_actif?

    [ true, MiseEnAction::REPONSE_PAS_ENCORE, false ]
  end
end
