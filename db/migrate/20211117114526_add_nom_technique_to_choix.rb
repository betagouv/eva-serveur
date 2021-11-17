class AddNomTechniqueToChoix < ActiveRecord::Migration[6.1]
  def change
    add_column :choix, :nom_technique, :string
  end
end
