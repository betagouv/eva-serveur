class AddCategorieToParcoursType < ActiveRecord::Migration[7.0]
  def change
    add_column :parcours_type, :categorie, :string
  end
end
