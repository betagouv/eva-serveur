class AjoutePositionnementNiveauNumeratieEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_column :evaluations, :positionnement_niveau_numeratie, :string
  end
end
