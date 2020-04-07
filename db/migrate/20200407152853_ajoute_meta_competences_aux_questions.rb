class AjouteMetaCompetencesAuxQuestions < ActiveRecord::Migration[6.0]
  def change
    add_column :questions, :metacompetence, :integer
  end
end
