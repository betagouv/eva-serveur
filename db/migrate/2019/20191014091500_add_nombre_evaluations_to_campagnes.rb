class AddNombreEvaluationsToCampagnes < ActiveRecord::Migration[6.0]
  def change
    add_column :campagnes, :nombre_evaluations, :integer, default: 0
  end
end
