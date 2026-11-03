# Tous les blocs (question, qualification, réponses) sont rendus ; le JS partagé
# avec le tableau de bord (mise_en_action.js.erb) n'en montre qu'un selon l'état.
class SuiviAccompagnementIllettrismeComponent < ViewComponent::Base
  def initialize(evaluation:)
    @evaluation = evaluation
  end

  def reponses
    reponses = [ true, false ]
    reponses << MiseEnAction::REPONSE_JE_NE_SAIS_PAS if MiseEnAction.je_ne_sais_pas_actif?
    reponses
  end
end
