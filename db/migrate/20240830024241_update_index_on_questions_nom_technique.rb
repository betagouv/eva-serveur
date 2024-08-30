class UpdateIndexOnQuestionsNomTechnique < ActiveRecord::Migration[7.0]
  def change
    remove_index :questions, :nom_technique

    add_index :questions, :nom_technique, unique: true, where: "deleted_at IS NULL"
  end
end
