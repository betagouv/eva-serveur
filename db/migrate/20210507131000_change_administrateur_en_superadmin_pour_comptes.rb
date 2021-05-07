class ChangeAdministrateurEnSuperadminPourComptes < ActiveRecord::Migration[6.1]
  class Compte < ApplicationRecord; end

  def up
    Compte.where(role: 'administrateur').update_all(role: 'superadmin')
  end

  def down
    Compte.where(role: 'superadmin').update_all(role: 'administrateur')
  end
end
