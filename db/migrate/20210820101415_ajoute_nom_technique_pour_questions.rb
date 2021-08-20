class AjouteNomTechniquePourQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :nom_technique, :string
  end
end
