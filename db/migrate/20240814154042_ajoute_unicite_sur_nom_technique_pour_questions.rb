class AjouteUniciteSurNomTechniquePourQuestions < ActiveRecord::Migration[7.0]
  def change
    add_index :questions, :nom_technique, unique: true
  end
end
