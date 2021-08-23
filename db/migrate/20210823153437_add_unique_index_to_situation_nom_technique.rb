class AddUniqueIndexToSituationNomTechnique < ActiveRecord::Migration[6.1]
  def change
    add_index :situations, :nom_technique, unique: true
  end
end
