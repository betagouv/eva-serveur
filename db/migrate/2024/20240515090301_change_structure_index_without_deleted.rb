class ChangeStructureIndexWithoutDeleted < ActiveRecord::Migration[7.0]
  def up
    remove_index :structures, [:nom, :code_postal]
    add_index :structures, [:nom, :code_postal], unique: true, where: "deleted_at IS NULL"
  end

  def down
    remove_index :structures, [:nom, :code_postal]
    add_index :structures, [:nom, :code_postal], unique: true
  end
end
