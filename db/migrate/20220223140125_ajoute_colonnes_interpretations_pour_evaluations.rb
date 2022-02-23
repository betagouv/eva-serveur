class AjouteColonnesInterpretationsPourEvaluations < ActiveRecord::Migration[6.1]
  def change
    add_column :evaluations, :synthese_competences_de_base, :string
    add_column :evaluations, :niveau_cefr, :string
    add_column :evaluations, :niveau_cnef, :string
    add_column :evaluations, :niveau_anlci_litteratie, :string
    add_column :evaluations, :niveau_anlci_numeratie, :string
  end
end
