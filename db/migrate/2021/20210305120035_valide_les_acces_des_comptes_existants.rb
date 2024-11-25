class ValideLesAccesDesComptesExistants < ActiveRecord::Migration[6.1]
  class Compte < ApplicationRecord; end

  def up
    Compte.update_all statut_validation: :acceptee
  end

  def down
    Compte.update_all statut_validation: 0
  end
end
