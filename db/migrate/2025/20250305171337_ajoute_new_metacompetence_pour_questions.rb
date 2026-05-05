class AjouteNewMetacompetencePourQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :new_metacompetence, :string
  end
end
