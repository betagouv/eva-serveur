require Rails.root.join("lib/rake_logger")

namespace :donnees_socio_demographique do
  desc "Supprime les données socio démographique en double"
  task supprimer_doublons: :environment do
    logger = RakeLogger.logger

    doublons = recupere_doublons

    total = doublons.count
    count = 0
    logger.info "Nombre de doublons : #{total}"
    doublons.find_each do |donnee_socio_demographique|
      count += 1
      logger.info "#{count}/#{total}"

      if DonneeSociodemographique
         .with_deleted.where(evaluation_id: donnee_socio_demographique.evaluation_id)
         .where.not(id: donnee_socio_demographique.id)
         .exists?
        donnee_socio_demographique.really_destroy!
      end
    end
    logger.info "C'est fini"
  end

  desc "Persiste les données sociodémographiques (dont santé) de la dernière partie Bienvenue " \
       "terminée de chaque évaluation"
  task persiste_donnees_sante: :environment do
    logger = RakeLogger.logger
    situation_bienvenue = Situation.find_by(nom_technique: Situation::BIENVENUE)

    if situation_bienvenue.nil?
      logger.error "Situation \"#{Situation::BIENVENUE}\" non trouvée"
      next
    end

    partie_ids_par_evaluation = recupere_partie_ids_bienvenue_par_evaluation(situation_bienvenue)

    total = partie_ids_par_evaluation.size
    logger.info "#{total} évaluations à traiter"

    traitees = 0
    partie_ids_par_evaluation.each_value do |partie_ids|
      persiste_derniere_partie_bienvenue_terminee(partie_ids)

      traitees += 1
      logger.info "#{traitees}/#{total}" if (traitees % 1000).zero?
    end
    logger.info "C'est fini"
  end
end

def recupere_partie_ids_bienvenue_par_evaluation(situation_bienvenue)
  Partie.where(situation: situation_bienvenue)
        .where.not(evaluation_id: nil)
        .order(created_at: :desc)
        .pluck(:evaluation_id, :id)
        .group_by(&:first)
        .transform_values { |paires| paires.map(&:second) }
end

def persiste_derniere_partie_bienvenue_terminee(partie_ids)
  partie_ids.each do |partie_id|
    partie = Partie.find(partie_id)
    next if partie.evaluation.nil?

    restitution = FabriqueRestitution.instancie(partie)
    next if restitution.evenements.empty?
    next unless restitution.termine?

    restitution.persiste
    break
  end
end

def recupere_doublons
  evaluation_ids = DonneeSociodemographique.with_deleted
                                           .select(:evaluation_id)
                                           .group(:evaluation_id)
                                           .having("count(*) > 1")
                                           .select(:evaluation_id)
  DonneeSociodemographique.with_deleted
                          .where(evaluation_id: evaluation_ids)
end
