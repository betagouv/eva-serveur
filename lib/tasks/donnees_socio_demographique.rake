# frozen_string_literal: true

require "rake_logger"

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
