# frozen_string_literal: true

require 'rake_logger'

namespace :beneficiaires do
  desc 'Crée les bénéficiaires des évaluations existantes'
  task cree_beneficiaire_des_evaluations: :environment do
    logger = RakeLogger.logger
    evaluations = Evaluation.where(beneficiaire_id: nil)
    nombre_eval = evaluations.count
    logger.info "Nombre d'évaluations : #{nombre_eval}"
    evaluations.find_each do |evaluation|
      evaluation.update(beneficiaire_attributes: { nom: evaluation.nom })

      nombre_eval -= 1
      logger.info "reste #{nombre_eval}"
    end
    logger.info "C'est fini"
  end
end
