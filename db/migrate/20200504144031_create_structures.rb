class CreateStructures < ActiveRecord::Migration[6.0]
  def change
    create_table :structures, id: :uuid do |t|
      t.string :nom
      t.string :code_postal

      t.timestamps
    end
  end
end
