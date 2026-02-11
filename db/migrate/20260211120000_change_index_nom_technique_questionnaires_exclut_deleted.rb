class ChangeIndexNomTechniqueQuestionnairesExclutDeleted < ActiveRecord::Migration[7.2]
  def change
    remove_index :questionnaires, :nom_technique
    add_index :questionnaires, :nom_technique, unique: true, where: 'deleted_at IS NULL'
  end
end
