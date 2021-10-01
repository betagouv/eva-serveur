class SupprimeSituationEtEvaluationSurEvenements < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :evenements, :evaluations
    remove_foreign_key :evenements, :situations
  end
end
