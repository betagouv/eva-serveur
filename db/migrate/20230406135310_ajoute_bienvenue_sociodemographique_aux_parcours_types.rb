class AjouteBienvenueSociodemographiqueAuxParcoursTypes < ActiveRecord::Migration[7.0]
  def change
    situation_bienvenue = Situation.find_by nom_technique: Situation::BIENVENUE
    questionnaire_socio =
      Questionnaire.find_by nom_technique: Questionnaire::SOCIODEMOGRAPHIQUE
    ParcoursType.all.each do |parcours_type|
        configuration_bienvenue = parcours_type.situations_configurations.where(situation: situation_bienvenue)
        if configuration_bienvenue.present?
          configuration_bienvenue.update(position: 0, questionnaire: questionnaire_socio)
        else
          parcours_type.situations_configurations.create situation_id: situation_bienvenue.id,
                                                        questionnaire_id: questionnaire_socio.id,
                                                        position: 0
        end
    end
  end
end
