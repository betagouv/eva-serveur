# frozen_string_literal: true

namespace :nettoyage do
  desc "Recalculer les metriques d'une situation."
  task recalcule_metriques: :environment do
    arg_situation = 'SITUATION'
    logger = RakeLogger.logger
    unless ENV.key?(arg_situation)
      logger.error "La variable d'environnement #{arg_situation} est marquante"
      logger.info 'Usage : rake nettoyage:recalcule_metriques SITUATION=<nom_technique>'
      exit
    end

    situation = Situation.find_by(nom_technique: ENV[arg_situation])
    if situation.nil?
      logger.error "Situation \"#{ENV[arg_situation]}\" non trouvé"
      exit
    end

    nombre_partie = Partie.where(situation: situation).count
    logger.info "Recalcule les #{nombre_partie} parties de la situation #{ENV['SITUATION']}…"
    Partie
      .where(situation: situation)
      .find_each do |partie|
        restitution = FabriqueRestitution.instancie partie.id
        restitution.persiste if restitution.termine?
        nombre_partie -= 1
        logger.info "reste #{nombre_partie}"
      end
    logger.info "C'est fini"
  end

  desc 'Ajoute les événements terminés'
  task ajoute_evenements_termines: :environment do
    Partie.find_each do |partie|
      evenements = Evenement.where(partie: partie)
      next if evenements.where(nom: 'finSituation').exists?

      restitution = FabriqueRestitution.instancie partie.id
      next unless restitution.termine?

      dernier_evenement = evenements.order(:date).last
      Evenement.create! partie: partie, nom: 'finSituation', date: dernier_evenement.date + 0.001
    end
  end

  desc 'Supprime les événements après la fin'
  task supprime_evenements_apres_la_fin: :environment do
    logger = RakeLogger.logger
    logger.info 'Evenements effacées:'
    Partie.find_each do |partie|
      date_fin = nil
      evenements = Evenement.where(partie: partie).order(:date)
      evenements_jusqua_fin = evenements.take_while do |evenement|
        date_fin ||= evenement.date if evenement.nom == 'finSituation'

        date_fin.nil? || evenement.date == date_fin
      end

      evenements_apres_fin = evenements - evenements_jusqua_fin
      evenements_apres_fin.each { |evenement| logger.info evenement }
      Evenement.where(id: evenements_apres_fin.collect(&:id)).destroy_all
    end
  end

  desc 'Assure une date de fin correcte'
  task date_evenements_fin: :environment do
    logger = RakeLogger.logger
    logger.info "Décale événements fin qui ont la mieme date que l'événement précédent..."

    Partie.find_each do |partie|
      derniers_evenements = Evenement.order(:date).where(partie: partie).last(2)
      next if derniers_evenements.count < 2 ||
              derniers_evenements.first.date != derniers_evenements.last.date

      fin = derniers_evenements.detect { |e| e.nom == 'finSituation' }

      next if fin.blank?

      fin.date += 0.001
      logger.info "Nouvelle date pour l'événement ##{fin.id} : #{fin.date}"
      fin.save!
    end
  end
end

class RakeLogger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
