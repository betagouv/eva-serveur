class AjouteColonneEmailBienvenueEnvoyeACompte < ActiveRecord::Migration[7.0]
  class Compte < ApplicationRecord; end

  def up
    add_column :comptes, :email_bienvenue_envoye, :boolean
    Compte.update_all(email_bienvenue_envoye: true)
  end

  def down
    remove_column :comptes, :email_bienvenue_envoye
  end
end
