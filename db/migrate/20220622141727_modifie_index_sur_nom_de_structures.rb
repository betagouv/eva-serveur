class ModifieIndexSurNomDeStructures < ActiveRecord::Migration[7.0]
  def change
    remove_index :structures, :nom, unique: true
    add_index :structures, [:nom, :code_postal], unique: true
  end
end
