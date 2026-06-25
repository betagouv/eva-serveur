class InitialiseTypePourEvaluation < ActiveRecord::Migration[7.2]
  def up
    Evaluation.update_all(type: "EvaluationEva")
    evaluations_evapro = Evaluation.joins(campagne: :parcours_type).where(campagnes: { parcours_type: { type_de_programme: :diagnostic_entreprise } } )

    evaluations_evapro.update_all(type: "EvaluationEvapro")
  end

  def down
    Evaluation.update_all(type: nil)
  end
end
