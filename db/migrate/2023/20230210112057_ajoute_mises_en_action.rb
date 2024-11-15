class AjouteMisesEnAction < ActiveRecord::Migration[7.0]
  def change
    create_table :mises_en_action, id: :uuid do |t|
      t.boolean :effectuee, null: false
      t.datetime :repondue_le
      t.string :dispositif_de_remediation
      t.datetime :deleted_at
      t.index :deleted_at, name: "index_mises_en_action_on_deleted_at"
      t.references :evaluation, index: true, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
