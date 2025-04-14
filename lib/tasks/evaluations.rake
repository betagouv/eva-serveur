# frozen_string_literal: true

require "rake_logger"

namespace :evaluations do
  desc "calcule les restitutions pour l'ensemble des évaluations"
  task calcule_restitution: :environment do
    logger = RakeLogger.logger
    evaluations = Evaluation
    if ENV.key?("CAFE_DE_LA_PLACE_SEULEMENT")
      parties = Partie.where(situation: Situation.where(nom_technique: "cafe_de_la_place"))
      evaluations = evaluations.where(parties: parties)
    end
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
