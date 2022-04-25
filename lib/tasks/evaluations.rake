# frozen_string_literal: true

require 'rake_logger'

namespace :evaluations do
  desc "calcule les restitutions pour l'ensemble des évaluations"
  task calcule_restitution: :environment do
    evaluations = Evaluation.where.not(terminee_le: nil)
                            .where(synthese_competences_de_base: nil)
    evaluations.find_each do |evaluation|
      restitution_globale = FabriqueRestitution.restitution_globale(evaluation)
      restitution_globale.persiste
    end
  end
end
