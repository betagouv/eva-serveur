class AjouteIndexUnicitePourChoix < ActiveRecord::Migration[7.2]
  def change
    add_index :choix, %i[nom_technique question_id], unique: true
  end
end
