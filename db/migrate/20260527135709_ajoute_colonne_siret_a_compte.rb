class AjouteColonneSiretACompte < ActiveRecord::Migration[7.2]
  def change
    # Renomme la colonne qui est en réalité utilisée pour
    # enregistrer le SIRET saisi pendant l'embarquement.
    rename_column :comptes, :siret_pro_connect, :siret
    add_column :comptes, :siret_pro_connect, :string
  end
end
