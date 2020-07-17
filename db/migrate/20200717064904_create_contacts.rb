class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.string :nom
      t.string :email
      t.references :compte, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
