class AjouteTypePourStructures < ActiveRecord::Migration[6.1]
  def change
    add_column :structures, :type, :string
    add_index :structures, :type
  end
end
