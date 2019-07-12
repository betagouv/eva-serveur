class AddQuestionnaireToCampagne < ActiveRecord::Migration[5.2]
  def change
    add_reference :campagnes, :questionnaire, foreign_key: true
  end
end
