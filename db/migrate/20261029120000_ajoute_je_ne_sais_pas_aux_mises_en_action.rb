class AjouteJeNeSaisPasAuxMisesEnAction < ActiveRecord::Migration[8.0]
  def change
    change_column_null :mises_en_action, :effectuee, true
    add_column :mises_en_action, :motif, :string
    add_column :mises_en_action, :date_revue, :date
  end
end
