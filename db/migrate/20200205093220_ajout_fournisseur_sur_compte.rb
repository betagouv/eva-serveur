class AjoutFournisseurSurCompte < ActiveRecord::Migration[6.0]
  def change
    add_column :comptes, :fournisseur, :string
    add_column :comptes, :fournisseur_uid, :string
  end
end
