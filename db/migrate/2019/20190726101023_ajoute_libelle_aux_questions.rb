class AjouteLibelleAuxQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :libelle, :string
  end
end
