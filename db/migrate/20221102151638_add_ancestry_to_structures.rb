class AddAncestryToStructures < ActiveRecord::Migration[7.0]
  def change
    add_column :structures, :ancestry, :string
    add_index :structures, :ancestry
  end
end
