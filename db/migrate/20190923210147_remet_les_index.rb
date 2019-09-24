class RemetLesIndex < ActiveRecord::Migration[5.2]
  def change
    add_index 'active_storage_attachments', 'blob_id'
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
    add_index 'active_admin_comments', ["resource_type", "resource_id"]
    add_index 'active_storage_attachments', ["record_type", "record_id", "name", "blob_id"], name: 'index_active_storage_attachments_uniqueness', unique: true
  end
end
