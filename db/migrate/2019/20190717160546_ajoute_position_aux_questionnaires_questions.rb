class AjoutePositionAuxQuestionnairesQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questionnaires_questions, :position, :integer
  end
end
