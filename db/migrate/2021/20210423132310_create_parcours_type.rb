class CreateParcoursType < ActiveRecord::Migration[6.1]
  def change
    create_table :parcours_type, id: :uuid do |t|
      t.string :libelle
      t.string :nom_technique
      t.string :duree_moyenne

      t.timestamps
    end
  end
end
