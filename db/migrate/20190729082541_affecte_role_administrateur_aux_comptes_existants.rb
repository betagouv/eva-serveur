class AffecteRoleAdministrateurAuxComptesExistants < ActiveRecord::Migration[5.2]
  def change
    Compte.where(role: nil).update_all(role: 'administrateur')
  end
end
