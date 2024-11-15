class RenommeCategorieEnTypeDeProgramme < ActiveRecord::Migration[7.0]
  def change
    rename_column :parcours_type, :categorie, :type_de_programme
  end
end
