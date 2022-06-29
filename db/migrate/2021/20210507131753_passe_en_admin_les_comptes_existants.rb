class PasseEnAdminLesComptesExistants < ActiveRecord::Migration[6.1]
  class Compte < ApplicationRecord; end

  def up
    Compte.where(role: 'organisation').update_all(role: 'admin')
  end

  def down
    Compte.where(role: 'admin').update_all(role: 'organisation')
  end
end
