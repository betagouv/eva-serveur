class AjouteScoreAuxChoix < ActiveRecord::Migration[8.0]
  def change
    add_column :choix, :score, :jsonb
  end
end
