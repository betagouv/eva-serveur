class RemetLesIndex < ActiveRecord::Migration[5.2]
  def change
    add_index 'campagnes', 'questionnaire_id'
    add_index 'campagnes', 'compte_id'
    add_index 'choix', 'question_id'
    add_index 'evaluations', 'campagne_id'
    add_index 'evenements', 'evaluation_id'
    add_index 'evenements', 'situation_id'
    add_index 'questionnaires_questions', 'questionnaire_id'
    add_index 'questionnaires_questions', 'question_id'
    add_index 'situations_configurations', 'campagne_id'
    add_index 'situations_configurations', 'situation_id'
  end
end
