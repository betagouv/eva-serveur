class NomDeStructuresEstUnique < ActiveRecord::Migration[7.0]
  def change
    add_index :structures, :nom, unique: true
  end
end
