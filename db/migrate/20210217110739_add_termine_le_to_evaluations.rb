class AddTermineLeToEvaluations < ActiveRecord::Migration[6.1]
  def change
    add_column :evaluations, :terminee_le, :datetime
    Evenement
      .joins(partie: :evaluation)
      .joins(partie: :situation)
      .where(nom: 'finSituation')
      .where('partie.situation': Situation.where(nom_technique: 'objets_trouves'))
      .group('evaluations.id')
      .pluck('max(evenements.created_at)', 'evaluations.id')
      .each do |date_creation_dernier_evenement, id_evaluation|
      Evaluation.find(id_evaluation).update(terminee_le: date_creation_dernier_evenement)
    end
  end
end
