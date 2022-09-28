class AddTermineLeToEvaluations < ActiveRecord::Migration[6.1]
  class Evenement < ApplicationRecord
    belongs_to :partie, foreign_key: :session_id, primary_key: :session_id
  end

  class Evaluation < ApplicationRecord
    default_scope {}
  end

  class Partie < ApplicationRecord
    belongs_to :evaluation
    belongs_to :situation
  end

  def change
    add_column :evaluations, :terminee_le, :datetime
    Evenement
      .joins(partie: :evaluation)
      .joins(partie: :situation)
      .where(nom: 'finSituation')
      .where('parties.situation': Situation.where(nom_technique: 'objets_trouves'))
      .group('evaluations.id')
      .pluck('max(evenements.created_at)', 'evaluations.id')
      .each do |date_creation_dernier_evenement, id_evaluation|
      Evaluation.find(id_evaluation).update(terminee_le: date_creation_dernier_evenement)
    end
  end
end
