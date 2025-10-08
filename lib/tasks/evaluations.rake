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

  desc "Persiste les réponses aux exercice de rédactions dans évaluations"
  task persiste_redactions: :environment do
    logger = RakeLogger.logger

    evaluation_ids = Evaluation.pluck(:id)
    total = evaluation_ids.count

    logger.info "Traitement de #{total} évaluations"

    evaluation_ids.each_slice(1000).with_index do |batch_ids, index|
      logger.info "Traitement du lot #{index + 1} (#{batch_ids.count} évaluations)"

      reponses_redaction = Evaluation.reponses_redaction_pour_evaluations(batch_ids)

      batch_ids.each do |evaluation_id|
        redactions = reponses_redaction[evaluation_id]
        Evaluation.where(id: evaluation_id).update_all(redactions: redactions)
      end
    end

    logger.info "C'est fini - #{total} évaluations traitées"
  end
end
