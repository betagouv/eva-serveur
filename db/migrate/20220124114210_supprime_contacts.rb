class SupprimeContacts < ActiveRecord::Migration[6.1]
  def change
    drop_table :contacts, id: :uuid do |t|
      t.string :nom
      t.string :email
      t.string :telephone
      t.references :compte, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
