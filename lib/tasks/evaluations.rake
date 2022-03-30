# frozen_string_literal: true

require 'rake_logger'

namespace :evaluations do
  desc 'calcule les restitutions pour les évaluations sans donnée'
  task calcule_restitution: :environment do
    evaluations = Evaluation.where.not(terminee_le: nil)
    logger = RakeLogger.logger
    nombre_eval = evaluations.count
    logger.info "Nombre d'évaluation : #{nombre_eval}"
    evaluations.find_each do |evaluation|
      restitution_globale = FabriqueRestitution.restitution_globale(evaluation)
      restitution_globale.persiste
      nombre_eval -= 1
      logger.info "reste #{nombre_eval}"
    end
    logger.info "C'est fini"
  end
end
