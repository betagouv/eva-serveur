class EvaluationEvapro < Evaluation
  SITUATION_COMPETENCES_EVAPRO = [
    Situation::DIAG_RISQUES_ENTREPRISE,
    Situation::EVALUATION_IMPACT_GENERAL
  ].freeze

  def opco_financeur
    diagnostic_pro&.opco_financeur
  end

  def opco
    diagnostic_pro&.opco
  end

  def evapro?
    true
  end

  def diagnostic_pro
    @diagnostic_pro ||= Evaluations::DiagnosticPro.new(self)
  end
end
