class AjouteTranscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :transcriptions, id: :uuid do |t|
      t.text :ecrit
      t.integer :categorie, default: 0
      t.references :question, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
