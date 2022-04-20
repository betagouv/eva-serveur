class AjouteTermineeSurEvaluations < ActiveRecord::Migration[6.1]
  def change
    add_column :evaluations, :terminee, :boolean, default: false, null: false
  end
end
