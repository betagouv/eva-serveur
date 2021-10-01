class AjouteForeignKeyAuxQuestionnaire < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :questionnaires_questions, :questionnaires
  end
end
