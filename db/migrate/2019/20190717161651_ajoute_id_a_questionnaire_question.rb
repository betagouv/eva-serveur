class AjouteIdAQuestionnaireQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questionnaires_questions, :id, :primary_key
  end
end
