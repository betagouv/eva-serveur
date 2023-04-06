class AjouteBienvenueSociodemographiqueAuxParcoursTypes < ActiveRecord::Migration[7.0]
  class Situation < ApplicationRecord; end
  class Questionnaire < ApplicationRecord; end
  class ParcoursType < ApplicationRecord
    has_many :situations_configurations, lambda {
                                           order(position: :asc)
                                         }, dependent: :destroy
  end

  def change
    situation_bienvenue = Situation.find_by nom_technique: ::Situation::BIENVENUE
    questionnaire_socio =
      Questionnaire.find_by nom_technique: ::Questionnaire::SOCIODEMOGRAPHIQUE
    ParcoursType.all.each do |parcours_type|
      parcours_type.situations_configurations.create situation_id: situation_bienvenue.id,
                                                     questionnaire_id: questionnaire_socio.id,
                                                     position: 0
    end
  end
end
