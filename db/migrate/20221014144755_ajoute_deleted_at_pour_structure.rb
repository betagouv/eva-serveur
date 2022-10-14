class AjouteDeletedAtPourStructure < ActiveRecord::Migration[7.0]
  def change
    add_column :structures, :deleted_at, :datetime
    add_index :structures, :deleted_at
  end
end
