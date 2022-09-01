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

  desc 'Supprime les bénéficiaires sans évaluations'
  task supprimer_les_beneficiaires_sans_evaluations: :environment do
    logger = RakeLogger.logger

    beneficiaire_avec_evaluation_ids = Evaluation.where.not(beneficiaire_id: nil)
                                                 .pluck(:beneficiaire_id)

    beneficiaires_sans_evaluation = Beneficiaire.where.not(id: beneficiaire_avec_evaluation_ids)
    total = beneficiaires_sans_evaluation.count
    count = 0
    logger.info "Nombre de bénéficiaire sans évaluation à supprimer : #{total}"
    beneficiaires_sans_evaluation.find_each do |beneficiaire|
      beneficiaire.destroy
      count += 1
      logger.info "#{count}/#{total}"
    end
    logger.info "C'est fini"
  end
end
