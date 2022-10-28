class AjouteStatutAuxEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_column :evaluations, :statut, :integer, default: 0, null: false
    add_index :evaluations, :statut
  end
end
