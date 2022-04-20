# frozen_string_literal: true

require 'rake_logger'

namespace :evaluations do
  desc "calcule les restitutions pour l'ensemble des évaluations"
  task calcule_restitution: :environment do
    logger = RakeLogger.logger
    nombre_eval = Evaluation.count
    logger.info "Nombre d'évaluation : #{nombre_eval}"
    Evaluation.find_each do |evaluation|
      restitution_globale = FabriqueRestitution.restitution_globale(evaluation)
      restitution_globale.persiste
      nombre_eval -= 1
      logger.info "reste #{nombre_eval}"
    end
    logger.info "C'est fini"
  end
end
