class AjouteUniciteSurEvenements < ActiveRecord::Migration[6.1]
  def change
    remove_index :evenements, [:session_id, :position]
    add_index :evenements, [:position, :session_id], unique: true
  end
end
