class NomDeStructuresEstUnique < ActiveRecord::Migration[7.0]
  def change
    add_index :structures, [:nom, :code_postal], unique: true
  end
end
