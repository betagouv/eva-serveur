class DefinisSituationInventaireEnFinDeParcours < ActiveRecord::Migration[6.1]
  def up
    situation_inventaire = Situation.find_by(nom_technique: 'inventaire')
    return if situation_inventaire.blank?

    situations_configurations = SituationConfiguration.where(situation_id: situation_inventaire.id)

    situations_configurations.each do |situation_configuration|
      situation_configuration.move_to_bottom
    end
  end
end
