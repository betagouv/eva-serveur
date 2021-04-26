class SupprimeSituationControleDeParcoursTypeComplet < ActiveRecord::Migration[6.1]
  def up
    parcours_type = ParcoursType.find_by nom_technique: 'complet'
    return if parcours_type.blank?

    situation_controle = Situation.find_by nom_technique: 'controle'
    SituationConfiguration.find_by(
      parcours_type_id: parcours_type.id,
      situation_id: situation_controle.id
    ).destroy
  end
end
