class SupprimeScoreDeQuestions < ActiveRecord::Migration[7.2]
  def change
    remove_column :questions, :score, :float
  end
end
