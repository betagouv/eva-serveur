class AjouteDeletedAtPourCampagne < ActiveRecord::Migration[7.0]
  def change
    add_column :campagnes, :deleted_at, :datetime
    add_index :campagnes, :deleted_at
  end
end
