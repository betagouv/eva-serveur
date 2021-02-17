# frozen_string_literal: true

namespace :nettoyage do
  def anonymise_evaluations(rng, logger)
    Evaluation.all.each do |evaluation|
      nouveau_nom = "#{rng.compose(2)} #{rng.compose(3).upcase}"
      logger.info "#{evaluation.nom} est remplacé par #{nouveau_nom}"
      evaluation.nom = nouveau_nom
      evaluation.email = nil
      evaluation.telephone = nil
      evaluation.save
    end
  end

  def anonymise_contacts_et_comptes(rng, logger)
    Contact.delete_all
    Compte.all.each do |compte|
      next unless compte.role == 'organisation'

      nouvel_email = "#{rng.compose(2)}@#{rng.compose(3)}.fr"
      logger.info "#{compte.email} est remplacé par #{nouvel_email}"
      compte.email = nouvel_email
      compte.save
    end
  end

  def anonymise_structure(structure, nouveau_nom)
    return if structure.nil?

    structure.nom = nouveau_nom
    structure.save
  end

  def anonymise_campagnes_et_structures(rng, logger)
    type_structure = ['Mission ', 'ML ', 'Garantie Jeunes ', '',
                      'Association ', 'Mission Locale Jeunes de ']
    Campagne.all.each_with_index do |campagne, index|
      nouveau_nom = "#{type_structure[index % type_structure.size]}#{rng.compose(3)}"
      logger.info "#{campagne.libelle} est remplacé par #{nouveau_nom}"
      campagne.libelle = nouveau_nom
      campagne.save
      anonymise_structure(campagne.compte.structure, nouveau_nom)
    end
  end

  desc 'Anonymise la base de données en entier'
  task anonymise: :environment do
    logger = RakeLogger.logger
    rng = RandomNameGenerator.new

    anonymise_evaluations(rng, logger)
    anonymise_contacts_et_comptes(rng, logger)
    anonymise_campagnes_et_structures(rng, logger)
  end

  desc "Recalculer les metriques d'une situation."
  task recalcule_metriques: :environment do
    arg_situation = 'SITUATION'
    logger = RakeLogger.logger
    unless ENV.key?(arg_situation)
      logger.error "La variable d'environnement #{arg_situation} est marquante"
      logger.info 'Usage : rake nettoyage:recalcule_metriques SITUATION=<nom_technique>'
      next
    end

    situation = Situation.find_by(nom_technique: ENV[arg_situation])
    if situation.nil?
      logger.error "Situation \"#{ENV[arg_situation]}\" non trouvé"
      next
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

  desc 'Supprime la situation controle de toutes les campagnes'
  task supprime_controle_campagne: :environment do
    SituationConfiguration.where(situation: Situation.where(nom_technique: 'controle')).destroy_all
  end
end

class RakeLogger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
