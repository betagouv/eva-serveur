class AjouteNomTechniqueAQuestionnaire < ActiveRecord::Migration[6.1]
  def change
    add_column :questionnaires, :nom_technique, :string
  end
end
