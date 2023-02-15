class AjoutePositionnementNiveauLitteratieEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_column :evaluations, :positionnement_niveau_litteratie, :string
  end
end
