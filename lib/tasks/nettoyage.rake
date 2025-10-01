require "rake_logger"

namespace :nettoyage do
  def collecte_email(domaine)
    Compte.where("email LIKE ?", "%@#{domaine}").to_h do |compte|
      [ compte.email.split("@").first, compte ]
    end
  end

  def anonymise_comptes
    puts "\n-- anonymise les comptes --"
    Compte.find_each do |compte|
      next if compte.superadmin?

      print "."
      Anonymisation::Compte.new(compte).anonymise
    end
  end

  def anonymise_structures
    puts "\n-- anonymise les structures --"
    Structure.find_each do |structure|
      print "."
      Anonymisation::Structure.new(structure).anonymise
    end
  end

  def anonymise_campagnes
    puts "\n-- anonymise les campagnes --"
    Campagne.find_each do |campagne|
      print "."
      campagne.code = campagne.code.gsub(/[ -É]/, "")
      Anonymisation::Campagne.new(campagne).anonymise
    end
  end

  desc "Anonymise la base de données en entier"
  task anonymise: :environment do
    return if Rails.env.production?

    anonymise_comptes
    anonymise_campagnes
    anonymise_structures
  end

  desc "Recalculer les metriques d'une situation."
  task recalcule_metriques: :environment do
    arg_situation = "SITUATION"
    logger = RakeLogger.logger
    unless ENV.key?(arg_situation)
      logger.error "La variable d'environnement #{arg_situation} est manquante"
      logger.info "Usage : rake nettoyage:recalcule_metriques SITUATION=<nom_technique>"
      next
    end

    situation = Situation.find_by(nom_technique: ENV.fetch(arg_situation))
    if situation.nil?
      logger.error "Situation \"#{ENV.fetch(arg_situation)}\" non trouvé"
      next
    end

    nombre_partie = Partie.where(situation: situation).count
    logger.info "Recalcule les #{nombre_partie} parties de la situation #{ENV.fetch('SITUATION')}…"
    Partie.where(situation: situation).find_each do |partie|
      if partie.evaluation_id.present? && partie.evaluation.nil?
        partie.destroy
      else
        restitution = FabriqueRestitution.instancie partie
        restitution.persiste if restitution.termine?
      end
      nombre_partie -= 1
      logger.info "reste #{nombre_partie}"
    end
    logger.info "C'est fini"
  end

  desc "Ajoute les événements terminés"
  task ajoute_evenements_termines: :environment do
    Partie.find_each do |partie|
      evenements = Evenement.where(partie: partie)
      next if evenements.exists?(nom: "finSituation")

      restitution = FabriqueRestitution.instancie partie
      next unless restitution.termine?

      dernier_evenement = evenements.order(:date).last
      Evenement.create! partie: partie, nom: "finSituation", date: dernier_evenement.date + 0.001
    end
  end

  desc "Supprime les événements après la fin"
  task supprime_evenements_apres_la_fin: :environment do
    logger = RakeLogger.logger
    logger.info "Evenements effacées:"
    Partie.find_each do |partie|
      date_fin = nil
      evenements = Evenement.where(partie: partie).order(:position, :date)
      evenements_jusqua_fin = evenements.take_while do |evenement|
        date_fin ||= evenement.date if evenement.nom == "finSituation"

        date_fin.nil? || evenement.date == date_fin
      end

      evenements_apres_fin = evenements - evenements_jusqua_fin
      evenements_apres_fin.each { |evenement| logger.info evenement }
      Evenement.where(id: evenements_apres_fin.collect(&:id)).destroy_all
    end
  end

  desc "Assure une date de fin correcte"
  task date_evenements_fin: :environment do
    logger = RakeLogger.logger
    logger.info "Décale événements fin qui ont la mieme date que l'événement précédent..."

    Partie.find_each do |partie|
      derniers_evenements = Evenement.order(:date).where(partie: partie).last(2)
      next if derniers_evenements.count < 2 ||
              derniers_evenements.first.date != derniers_evenements.last.date

      fin = derniers_evenements.detect { |e| e.nom == "finSituation" }

      next if fin.blank?

      fin.date += 0.001
      logger.info "Nouvelle date pour l'événement ##{fin.id} : #{fin.date}"
      fin.save!
    end
  end

  desc "Supprime la situation controle de toutes les campagnes"
  task supprime_controle_campagne: :environment do
    SituationConfiguration.where(situation: Situation.where(nom_technique: "controle")).destroy_all
  end

  def supprime_espace_inutile(objet, attributs)
    changements = attributs.index_with do |str|
      objet.send(str)&.squish
    end
    objet.update(changements)
  end

  desc "Supprime les espaces inutiles pour les campagnes, comptes et structures"
  task supprime_espaces_inutiles: :environment do
    puts "\n-- campagnes --"
    Campagne.find_each do |campagne|
      supprime_espace_inutile(campagne, %i[libelle code])
      print "."
    end
    puts "\n-- comptes --"
    Compte.find_each do |compte|
      supprime_espace_inutile(compte, %i[email nom prenom telephone])
      print "."
    end
    puts "\n-- structures --"
    Structure.find_each do |structure|
      supprime_espace_inutile(structure, %i[nom code_postal])
      print "."
    end
  end

  desc "Supprime les illustrations des questions"
  task supprime_illustrations_questions: :environment do
    ActiveStorage::Blob.where(service_name: "openstack").find_each do |blob|
      ActiveStorage::Attachment.where(blob_id: blob.id).destroy_all
      blob.destroy
    end

    Question.find_each do |question|
      question.illustration.purge
      print "."
    end
  end

  desc "supprime les doublons"
  task supprime_doublons_evenements: :environment do
    logger = RakeLogger.logger

    evenements_en_double = Evenement.find_by_sql('select "session_id", "position"
from (select
        "session_id", "position",
        count(*) "evenementsParGroup"
    from evenements
    WHERE "evenements"."position" IS not NULL
    group by "session_id", "position"
    ) as "evenements_groupes"
where "evenementsParGroup" > 1')

    nombre_evenements = evenements_en_double.size
    logger.info "Nombre d'événements en double : #{nombre_evenements}"

    evenements_en_double.each do |evenement|
      doubles = Evenement.where(session_id: evenement.session_id,
                                position: evenement.position)
      first_id = doubles.first.id
      doubles.where.not(id: first_id).destroy_all

      nombre_evenements -= 1
      logger.info "Il reste #{nombre_evenements} événements en double"
    end
  end

  desc "migre les adresses pole-emploi.fr"
  task migrer_pole_emploi: :environment do
    logger = RakeLogger.logger

    adresses_pole_emploi = collecte_email("pole-emploi.fr")
    adresses_france_travail = collecte_email("francetravail.fr")

    cles_communes = adresses_pole_emploi.keys & adresses_france_travail.keys
    logger.info "Nombre de clés communes: #{cles_communes.count}"

    cles_communes.each do |cle|
      compte_pe = adresses_pole_emploi[cle]
      compte_ft = adresses_france_travail[cle]
      logger.info "analyse du compte : #{compte_pe.email}"
      logger.info "nombre de campagnes : #{Campagne.where(compte: compte_pe).count}"
      logger.info "Structure pe : #{compte_pe.structure.nom}"
      logger.info "Structure ft : #{compte_ft.structure&.nom}"
      if compte_pe.structure == compte_ft.structure
        Campagne.where(compte: compte_pe).update_all(compte_id: compte_ft.id)
        compte_pe.destroy if Campagne.where(compte: compte_pe).empty?
      end
    end
  end
end
