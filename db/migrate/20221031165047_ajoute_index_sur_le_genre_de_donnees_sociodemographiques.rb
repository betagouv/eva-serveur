class AjouteIndexSurLeGenreDeDonneesSociodemographiques < ActiveRecord::Migration[7.0]
  def change
    add_index :donnees_sociodemographiques, :genre
  end
end
