class AjouteDescriptionPourParcoursType < ActiveRecord::Migration[6.1]
  def change
    add_column :parcours_type, :description, :text
  end
end
