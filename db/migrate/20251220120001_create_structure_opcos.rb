class CreateStructureOpcos < ActiveRecord::Migration[7.2]
  def change
    create_table :structure_opcos, id: :uuid do |t|
      t.references :structure, null: false, foreign_key: false, type: :uuid
      t.references :opco, null: false, foreign_key: false, type: :uuid

      t.timestamps
    end

    add_index :structure_opcos, [:structure_id, :opco_id], unique: true
    add_foreign_key :structure_opcos, :structures, on_delete: :cascade
    add_foreign_key :structure_opcos, :opcos, on_delete: :cascade
  end
end
