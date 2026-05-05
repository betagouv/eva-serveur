class AjouteStatutSiretEtDateVerificationSiretPourStructures < ActiveRecord::Migration[7.2]
  def change
    add_column :structures, :statut_siret, :boolean, null: true
    add_column :structures, :date_verification_siret, :datetime
  end
end

