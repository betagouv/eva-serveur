class SupprimeColonneQuestions < ActiveRecord::Migration[5.2]
  def change
    remove_column :questionnaires, :questions, :jsonb
  end
end
