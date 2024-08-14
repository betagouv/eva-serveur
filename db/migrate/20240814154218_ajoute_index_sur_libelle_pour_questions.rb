class AjouteIndexSurLibellePourQuestions < ActiveRecord::Migration[7.0]
  def change
    add_index :questions, :libelle
  end
end
