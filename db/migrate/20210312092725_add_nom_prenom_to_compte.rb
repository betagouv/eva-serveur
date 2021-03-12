class AddNomPrenomToCompte < ActiveRecord::Migration[6.1]
  def change
    add_column :comptes, :nom, :string
    add_column :comptes, :prenom, :string
  end
end
