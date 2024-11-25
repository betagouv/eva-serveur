class MigreClesEtrangeres < ActiveRecord::Migration[5.2]
  class Evaluation < ApplicationRecord; end

  def up
    id_to_uuid('campagnes', 'questionnaire', 'questionnaire')
    id_to_uuid('campagnes', 'compte', 'compte')
    id_to_uuid('choix', 'question', 'question')
    id_to_uuid('evaluations', 'campagne', 'campagne', klass: Evaluation)
    id_to_uuid('evenements', 'evaluation', 'evaluation')
    id_to_uuid('evenements', 'situation', 'situation')
    id_to_uuid('questionnaires_questions', 'questionnaire', 'questionnaire')
    id_to_uuid('questionnaires_questions', 'question', 'question')
    id_to_uuid('situations_configurations', 'campagne', 'campagne')
    id_to_uuid('situations_configurations', 'situation', 'situation')
    id_to_uuid('active_storage_attachments', 'blob', 'blob', klass: ActiveStorage::Attachment, relation_klass: ActiveStorage::Blob)
  end

  def id_to_uuid(table_name, relation_name, relation_class, klass: nil, relation_klass: nil)
    table_name = table_name.to_sym
    klass ||= table_name.to_s.classify.constantize
    relation_klass ||= relation_class.to_s.classify.constantize
    foreign_key = "#{relation_name}_id".to_sym
    new_foreign_key = "#{relation_name}_uuid".to_sym

    add_column table_name, new_foreign_key, :uuid

    klass.unscoped.where.not(foreign_key => nil).each do |record|
      if associated_record = relation_klass.find_by(id: record.send(foreign_key))
        record.update_column(new_foreign_key, associated_record.uuid)
      end
    end

    remove_column table_name, foreign_key
    rename_column table_name, new_foreign_key, foreign_key
  end
end
