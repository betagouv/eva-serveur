class AjouteForeignKeyChoixQuestionSuppressionCascade < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :choix, :questions
    add_foreign_key :choix, :questions, on_delete: :cascade
  end
end
