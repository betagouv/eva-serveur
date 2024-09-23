class AjouteColonneIdProConnectAuxComptes < ActiveRecord::Migration[7.0]
  def change
    add_column :comptes, :id_pro_connect, :string
    add_index :comptes, :id_pro_connect
  end
end
