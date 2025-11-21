class RemoveOpcoIdFromStructures < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :structures, :opcos if foreign_key_exists?(:structures, :opcos)
    remove_index :structures, :opco_id if index_exists?(:structures, :opco_id)
    remove_column :structures, :opco_id, :uuid
  end
end
