class AjouteColonneSiretProconnectAuxComptes < ActiveRecord::Migration[7.0]
  def change
    add_column :comptes, :siret_pro_connect, :string
  end
end
