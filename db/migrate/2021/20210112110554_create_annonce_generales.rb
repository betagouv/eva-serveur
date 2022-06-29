class CreateAnnonceGenerales < ActiveRecord::Migration[6.0]
  def change
    create_table :annonce_generales, id: :uuid do |t|
      t.string :texte
      t.boolean :afficher

      t.timestamps
    end
  end
end
