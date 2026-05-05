class CreateOpcos < ActiveRecord::Migration[7.2]
  def change
    create_table :opcos, id: :uuid do |t|
      t.string :nom, null: false
      t.boolean :financeur, default: false

      t.timestamps
    end
  end
end
