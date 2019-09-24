class AjouteUuidAuxTables < ActiveRecord::Migration[5.2]
  def change
    tables = %w[
      active_admin_comments
      active_storage_attachments
      active_storage_blobs
      campagnes
      choix
      comptes
      evaluations
      evenements
      questionnaires
      questionnaires_questions
      questions
      situations
      situations_configurations
    ]
    tables.each do |table|
      add_column table, :uuid, :uuid, default: "gen_random_uuid()", null: false
    end

  end
end
