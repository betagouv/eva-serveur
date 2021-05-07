class RenommeOrganisationEnConseillerPourComptes < ActiveRecord::Migration[6.1]
  def up
    Compte.where(role: 'organisation').update_all(role: 'conseiller')
  end

  def down
    Compte.where(role: 'conseiller').update_all(role: 'organisation')
  end
end
