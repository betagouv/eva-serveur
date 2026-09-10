class AjouteDonneesSanteAuxDonneesSociodemographiques < ActiveRecord::Migration[7.2]
  def change
    add_column :donnees_sociodemographiques, :vue, :string
    add_column :donnees_sociodemographiques, :entendre, :string
    add_column :donnees_sociodemographiques, :trouble_dys, :string
    add_column :donnees_sociodemographiques, :difficultes_informatique, :string
  end
end
