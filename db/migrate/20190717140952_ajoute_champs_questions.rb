class AjouteChampsQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :type, :string
    add_column :questions, :description, :string
    add_column :questions, :entete_reponse, :string
    add_column :questions, :expediteur, :string
    add_column :questions, :message, :string
    add_column :questions, :objet_reponse, :string
  end
end
