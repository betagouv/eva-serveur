class AjouteConsigneAQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :modalite_reponse, :string
  end
end
