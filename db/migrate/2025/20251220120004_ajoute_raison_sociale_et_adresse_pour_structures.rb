class AjouteRaisonSocialeEtAdressePourStructures < ActiveRecord::Migration[7.0]
  def change
    add_column :structures, :raison_sociale, :string
    add_column :structures, :adresse, :text
  end
end

