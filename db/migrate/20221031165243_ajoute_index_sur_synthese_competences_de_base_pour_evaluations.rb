class AjouteIndexSurSyntheseCompetencesDeBasePourEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_index :evaluations, :synthese_competences_de_base
  end
end
