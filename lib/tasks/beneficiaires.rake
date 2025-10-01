require "rake_logger"

namespace :beneficiaires do
  desc "Supprime les bénéficiaires sans évaluations"
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
