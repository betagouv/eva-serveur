class AjouteArchiveAParcoursTypes < ActiveRecord::Migration[7.2]
  def change
    add_column :parcours_type, :actif, :boolean, default: true
  end
end
