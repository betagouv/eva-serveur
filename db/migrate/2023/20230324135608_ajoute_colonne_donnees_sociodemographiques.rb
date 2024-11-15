class AjouteColonneDonneesSociodemographiques < ActiveRecord::Migration[7.0]
  def change
    add_column :donnees_sociodemographiques, :langue_maternelle, :string
    add_column :donnees_sociodemographiques, :lieu_scolarite, :string
  end
end
