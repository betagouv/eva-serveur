class AssocieQuestionnaireASituation < ActiveRecord::Migration[6.0]
  def change
    add_reference :situations, :questionnaire, foreign_key: true, type: :uuid
  end
end
