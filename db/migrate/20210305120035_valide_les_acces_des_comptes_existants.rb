class ValideLesAccesDesComptesExistants < ActiveRecord::Migration[6.1]
  def up
    Compte.update_all statut_validation: :acceptee
  end

  def down
    Compte.update_all statut_validation: 0
  end
end
