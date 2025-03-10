class ValideLesAccesDesComptesExistants < ActiveRecord::Migration[6.1]
  class Compte < ApplicationRecord
    enum :statut_validation, { en_attente: 0, acceptee: 1, refusee: 2 }, prefix: :validation
  end

  def up
    Compte.update_all statut_validation: 1
  end

  def down
    Compte.update_all statut_validation: 0
  end
end
