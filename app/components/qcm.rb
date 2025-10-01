class Qcm < ViewComponent::Base
  include EvaluationHelper

  def initialize(ressource, questionnaire, qcm_affiche: true, priorite: nil)
    @ressource = ressource
    @questionnaire = questionnaire
    @qcm_affiche = qcm_affiche
    @priorite = priorite
  end
end
