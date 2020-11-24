class CreateActualites < ActiveRecord::Migration[6.0]
  def change
    create_table :actualites, id: :uuid do |t|
      t.string :titre
      t.text :contenu
      t.integer :categorie

      t.timestamps
    end
  end
end
