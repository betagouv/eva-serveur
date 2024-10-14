class AjouteReponseMaxlenghtToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :reponse_longueur_max, :integer
  end
end
