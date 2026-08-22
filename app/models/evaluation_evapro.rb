class EvaluationEvapro < Evaluation
  SITUATION_COMPETENCES_EVAPRO = [
    Situation::DIAG_RISQUES_ENTREPRISE,
    Situation::EVALUATION_IMPACT_GENERAL
  ].freeze

  SCORE_TO_LETTRE = {
    "faible" => "A",
    "moyen" => "B",
    "fort" => "C",
    "tres_fort" => "D"
  }.freeze

  NIVEAUX_COMPLETUDE = %w[incomplete complete].freeze

  enum :completude, NIVEAUX_COMPLETUDE.zip(NIVEAUX_COMPLETUDE).to_h

  def classe_restitution
    Restitution::GlobaleEvapro
  end

  def opco_financeur
    structure&.opco_financeur
  end

  def opco
    structure&.opco
  end

  def restitution_pro(restitution_globale)
    EvaluationsEvapro::Restitution.new(restitution_globale: restitution_globale)
  end

  def titre
    structure&.nom
  end
end
