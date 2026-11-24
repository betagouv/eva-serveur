class DetailsEvaluationComponent < ViewComponent::Base
  SCOPE = %i[admin evaluations_eva details_evaluation].freeze

  def initialize(evaluation:)
    @evaluation = evaluation
    @beneficiaire = evaluation.beneficiaire
    @campagne = evaluation.campagne
  end

  def incomplete?
    !@evaluation.complete?
  end

  def titre_alerte
    t(:titre, scope: scope_incompletude)
  end

  def description_alerte
    t(:description_html, scope: scope_incompletude)
  end

  private

  def scope_incompletude
    SCOPE + [ :incompletude, @evaluation.completude ]
  end
end
