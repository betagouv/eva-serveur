class AssocieQuestionnaireEntrainementSituation < ActiveRecord::Migration[6.0]
  def change
    add_reference :situations, :questionnaire_entrainement, type: :uuid

    add_foreign_key :situations, :questionnaires, column: :questionnaire_entrainement_id
  end
end
