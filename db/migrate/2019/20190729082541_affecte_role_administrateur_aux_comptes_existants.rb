class AffecteRoleAdministrateurAuxComptesExistants < ActiveRecord::Migration[5.2]
  class Compte < ApplicationRecord; end

  def up
    Compte.where(role: nil).update_all(role: 'administrateur')
  end
end
