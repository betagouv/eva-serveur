class SupprimeChampsSituationEtEvaluationSurEvenements < ActiveRecord::Migration[6.0]
  def change
    remove_column :evenements, :situation_id, :integer
    remove_column :evenements, :evaluation_id, :integer
  end
end
