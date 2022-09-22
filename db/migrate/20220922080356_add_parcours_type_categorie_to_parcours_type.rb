class AddParcoursTypeCategorieToParcoursType < ActiveRecord::Migration[7.0]
  def change
    add_reference :parcours_type, :parcours_type_categorie, null: true, foreign_key: true, type: :uuid
  end
end
