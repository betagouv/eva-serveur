class AjouteColonneIdInclusionConnectACompte < ActiveRecord::Migration[7.0]
  def change
    add_column :comptes, :id_inclusion_connect, :string
    add_index :comptes, :id_inclusion_connect
  end
end
