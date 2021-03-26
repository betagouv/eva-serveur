class RemplitlesPrenomNomVides < ActiveRecord::Migration[6.1]
  def change
    Compte.where(prenom: nil).update_all(prenom: 'n/c')
    Compte.where(nom: nil).update_all(nom: 'n/c')
  end
end
