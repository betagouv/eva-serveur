class AjouteColonneCguAcceptesACompte < ActiveRecord::Migration[7.0]
  def change
    add_column :comptes, :cgu_acceptees, :boolean
  end
end
