class AddStatutValidationToCompte < ActiveRecord::Migration[6.1]
  def change
    add_column :comptes, :statut_validation, :integer, default: 0
  end
end
