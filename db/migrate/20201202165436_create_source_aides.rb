class CreateSourceAides < ActiveRecord::Migration[6.0]
  def change
    create_table :source_aides, id: :uuid do |t|
      t.string :titre
      t.text :description
      t.string :url
      t.integer :categorie
      t.integer :type_document

      t.timestamps
    end
  end
end
