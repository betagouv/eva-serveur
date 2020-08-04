# frozen_string_literal: true

require 'rake_logger'

namespace :nettoyage do
  def anonymise_evaluations
    puts "\n-- anonymise les évaluations --"
    Evaluation.find_each do |evaluation|
      print '.'
      Anonymisation::Evaluation.new(evaluation).anonymise
    end
  end

  def anonymise_comptes
    puts "\n-- anonymise les comptes --"
    Compte.find_each do |compte|
      next if compte.superadmin?

      print '.'
      Anonymisation::Compte.new(compte).anonymise
    end
  end

  def anonymise_structures
    puts "\n-- anonymise les structures --"
    Structure.find_each do |structure|
      print '.'
      Anonymisation::Structure.new(structure).anonymise
    end
  end

  def anonymise_campagnes
    puts "\n-- anonymise les campagnes --"
    Campagne.find_each do |campagne|
      print '.'
      Anonymisation::Campagne.new(campagne).anonymise
    end
  end

  desc 'Anonymise la base de données en entier'
  task anonymise: :environment do
    return if Rails.env.production?

    anonymise_evaluations
    Contact.delete_all
    anonymise_comptes
    anonymise_campagnes
    anonymise_structures
  end

  def noms_colonnes(mes, colonnes, colonnes_z)
    noms = ""
    noms += "#{mes}: #{colonnes[mes].join("; #{mes}: ")};" unless colonnes[mes].empty?
    noms += "#{mes}: cote_z_#{colonnes_z[mes].join("; #{mes}: cote_z_")};" unless colonnes_z[mes].empty?
    noms
  end

  desc 'Extrait les données pour les psychologues'
  task extrait_stats: :environment do
    Rails.logger.level = :warn
    colonnes = {
      'bienvenue' => [],
      'maintenance' => Restitution::Maintenance::METRIQUES.keys,
      'livraison' => Restitution::Livraison::METRIQUES.keys,
      'objets_trouves' => Restitution::ObjetsTrouves::METRIQUES.keys
    }
    colonnes_z = {
      'bienvenue' => [],
      'maintenance' => Restitution::Maintenance::METRIQUES.keys,
      'livraison' => Restitution::Livraison::METRIQUES.keys,
      'objets_trouves' => Restitution::ObjetsTrouves::METRIQUES.keys
    }
    evaluations = Evaluation.joins(campagne: :compte).where(comptes: { role: :organisation })
    puts "Nombre d'évaluation : #{evaluations.count}"
    entete_colonnes = "campagne;nom evalué·e;date creation de la partie;"
    colonnes.keys.each do |mes|
      entete_colonnes += noms_colonnes(mes, colonnes, colonnes_z)
    end
    puts entete_colonnes
    evaluations.each do |e|
      situations = {}
      colonnes.keys.each do |mes|
        situations[mes] = Array.new(colonnes[mes].count + colonnes_z[mes].count, 'vide')
      end

      Partie.where(evaluation: e).order(:created_at).each do |partie|
        restitution = FabriqueRestitution.instancie partie.id
        next unless restitution.termine?

        situations[partie.situation.nom_technique] = []
        case partie.situation.nom_technique
        when 'bienvenue'
          restitution.questions_et_reponses.each do |question_et_reponse|
            reponse = question_et_reponse[:reponse]
            question = question_et_reponse[:question]
            situations[partie.situation.nom_technique] << question.libelle
            situations[partie.situation.nom_technique] << reponse.intitule
          end
        else
          colonnes[partie.situation.nom_technique]&.each do |metrique|
            valeur = partie.metriques[metrique]&.to_s || restitution.send(metrique)&.to_s
            situations[partie.situation.nom_technique] << (valeur || 'vide')
          end
          colonnes_z[partie.situation.nom_technique]&.each do |metrique|
            situations[partie.situation.nom_technique] << (restitution.cote_z_metriques[metrique] || 'vide')
          end
        end
      end
      valeurs_des_parties = situations.keys.map do |situation|
        situations[situation].join('; ')
      end
      puts "#{e.campagne&.libelle};#{e.nom};#{e.created_at};" + valeurs_des_parties.join('; ')
    end
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
        restitution = FabriqueRestitution.instancie partie
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
      next if evenements.exists?(nom: 'finSituation')

      restitution = FabriqueRestitution.instancie partie
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
      evenements = Evenement.where(partie: partie).order(:position, :date)
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

  def supprime_espace_inutile(objet, attributs)
    changements = attributs.index_with do |str|
      objet.send(str)&.squish
    end
    objet.update(changements)
  end

  desc 'Supprime les espaces inutiles pour les campagnes, comptes et structures'
  task supprime_espaces_inutiles: :environment do
    puts "\n-- campagnes --"
    Campagne.find_each do |campagne|
      supprime_espace_inutile(campagne, %i[libelle code])
      print '.'
    end
    puts "\n-- comptes --"
    Compte.find_each do |compte|
      supprime_espace_inutile(compte, %i[email nom prenom telephone])
      print '.'
    end
    puts "\n-- structures --"
    Structure.find_each do |structure|
      supprime_espace_inutile(structure, %i[nom code_postal])
      print '.'
    end
  end

  desc 'Supprime les illustrations des questions'
  task supprime_illustrations_questions: :environment do
    ActiveStorage::Blob.where(service_name: 'openstack').find_each do |blob|
      ActiveStorage::Attachment.where(blob_id: blob.id).destroy_all
      blob.destroy
    end

    Question.find_each do |question|
      question.illustration.purge
      print '.'
    end
  end
end
