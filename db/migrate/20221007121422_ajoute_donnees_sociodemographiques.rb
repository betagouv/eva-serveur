class AjouteDonneesSociodemographiques < ActiveRecord::Migration[7.0]
  def change
    create_table :donnees_sociodemographiques, id: :uuid do |t|
      t.integer :age
      t.string :genre
      t.string :dernier_niveau_etude
      t.string :derniere_situation
      t.references :evaluation, index: true, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
