class SupprimeQuestionnaireCampagnes < ActiveRecord::Migration[7.0]
  def change
    remove_column :campagnes, :questionnaire_id
  end
end
