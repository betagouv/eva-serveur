class AjouteColonneAfficheCompetencesFortesACampagne < ActiveRecord::Migration[6.0]
  def change
    add_column :campagnes, :affiche_competences_fortes, :boolean, default: true
  end
end
