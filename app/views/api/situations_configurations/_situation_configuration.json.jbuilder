# frozen_string_literal: true

json.id situation_configuration.situation_id
json.libelle situation_configuration.libelle
json.nom_technique situation_configuration.nom_technique

questionnaire = situation_configuration.questionnaire_utile
json.questionnaire_id questionnaire&.id
json.questionnaire do
  if questionnaire
    json.partial! 'api/questionnaires/questionnaire', questionnaire: questionnaire
  else
    json.null!
  end
end

questionnaire_entrainement = situation_configuration.situation.questionnaire_entrainement
json.questionnaire_entrainement_id questionnaire_entrainement&.id
json.questionnaire_entrainement do
  if questionnaire_entrainement
    json.partial! 'api/questionnaires/questionnaire', questionnaire: questionnaire_entrainement
  else
    json.null!
  end
end
