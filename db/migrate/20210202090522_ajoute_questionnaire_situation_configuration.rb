class AjouteQuestionnaireSituationConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :situations_configurations, :questionnaire_id, :uuid
  end
end
