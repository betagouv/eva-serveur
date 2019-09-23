class AjouteUuidAuxTables < ActiveRecord::Migration[5.2]
  def change
    tables = %w[
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
