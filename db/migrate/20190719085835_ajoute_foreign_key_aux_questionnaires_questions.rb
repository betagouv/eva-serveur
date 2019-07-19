class AjouteForeignKeyAuxQuestionnairesQuestions < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :questionnaires_questions, :questions
  end
end
