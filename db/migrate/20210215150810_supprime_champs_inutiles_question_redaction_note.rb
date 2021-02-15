class SupprimeChampsInutilesQuestionRedactionNote < ActiveRecord::Migration[6.1]
  def change
    remove_column :questions, :expediteur, :string
    rename_column :questions, :entete_reponse, :reponse_placeholder
    rename_column :questions, :objet_reponse, :intitule_reponse
  end
end
