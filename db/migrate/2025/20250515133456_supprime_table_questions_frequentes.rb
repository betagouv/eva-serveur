class SupprimeTableQuestionsFrequentes < ActiveRecord::Migration[7.2]
  def change
    drop_table :questions_frequentes
  end
end
