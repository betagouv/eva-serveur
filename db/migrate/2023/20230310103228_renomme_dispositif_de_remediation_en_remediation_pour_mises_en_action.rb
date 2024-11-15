class RenommeDispositifDeRemediationEnRemediationPourMisesEnAction < ActiveRecord::Migration[7.0]
  def change
    rename_column :mises_en_action, :dispositif_de_remediation, :remediation
  end
end
