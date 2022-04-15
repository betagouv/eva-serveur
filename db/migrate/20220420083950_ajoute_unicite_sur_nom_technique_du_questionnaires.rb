class AjouteUniciteSurNomTechniqueDuQuestionnaires < ActiveRecord::Migration[6.1]
  def change
    add_index :questionnaires, :nom_technique, unique: true
  end
end
