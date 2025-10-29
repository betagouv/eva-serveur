class AjouteSituationPlaceDuMarche < ActiveRecord::Migration[7.0]
  def up
    situation = Situation.with_deleted.find_or_create_by(nom_technique: 'place_du_marche') do |situation|
      situation.libelle = 'Place du marché'
    end
    situation.restore if situation.deleted?
  end

  def down
    Situation.find_by(nom_technique: 'place_du_marche')&.destroy
  end
end
