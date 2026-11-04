class AjouteChoixDateRevueAuxMisesEnAction < ActiveRecord::Migration[8.0]
  def change
    add_column :mises_en_action, :choix_date_revue, :string
  end
end
