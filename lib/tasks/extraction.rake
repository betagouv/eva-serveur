# frozen_string_literal: true

namespace :extraction do
  def noms_colonnes(mes, colonnes, colonnes_z)
    noms = ''
    noms += "#{mes}: #{colonnes[mes].join("; #{mes}: ")};" unless colonnes[mes].empty?
    unless colonnes_z[mes].empty?
      noms += "#{mes}: cote_z_#{colonnes_z[mes].join("; #{mes}: cote_z_")};"
    end
    noms
  end

  desc 'Extrait les données des questions'
  task questions: :environment do
    Rails.logger.level = :warn

    puts 'identifiant évaluation;MES;meta-competence;question;succes'

    # Maintenance
    sessions_ids_maintenance = Partie
                               .joins(:situation)
                               .where(situations: { nom_technique: :maintenance })
                               .select(:session_id)
    evenements = Evenement.where(nom: :identificationMot)
                          .where(session_id: sessions_ids_maintenance)
    evenements.each do |evt|
      succes = (evt.donnees['reponse'] == 'pasfrancais') == (evt.donnees['type'] == 'non-mot')
      puts "#{evt.session_id};maintenance;vocabulaire;#{evt.donnees['mot']};#{succes}"
    end

    # Objet trouves
    sessions_ids_objets_trouves = Partie
                                  .joins(:situation)
                                  .where(situations: { nom_technique: :objets_trouves })
                                  .select(:session_id)
    evenements = Evenement.where(nom: :reponse)
                          .where(session_id: sessions_ids_objets_trouves)
    evenements.each do |e|
      valeurs = "#{e.donnees['metacompetence']};#{e.donnees['question']};#{e.donnees['succes']}"
      puts "#{evt.session_id};objets_trouves;#{valeurs}"
    end

    # Livraison
    sessions_ids_livraison = Partie.joins(:situation)
                                   .where(situations: { nom_technique: :livraison })
                                   .select(:session_id)
    evenements = Evenement.where(nom: :reponse)
                          .where(session_id: sessions_ids_livraison)
    evenements.each do |evt|
      question = Question.find(evt.donnees['question'])
      metacompetence = question.metacompetence
      question = question.libelle
      reponse = Choix.find(evt.donnees['reponse'])
      succes = reponse.type_choix == 'bon'
      puts "#{evt.session_id};livraison;#{metacompetence};#{question};#{succes}"
    end
  end

  desc 'Extrait les données pour les psychologues'
  task stats: :environment do
    Rails.logger.level = :warn
    colonnes = {
      'maintenance' => Restitution::Maintenance::METRIQUES.keys,
      'livraison' => Restitution::Livraison::METRIQUES.keys,
      'objets_trouves' => Restitution::ObjetsTrouves::METRIQUES.keys,
      'bienvenue' => []
    }
    colonnes_z = {
      'bienvenue' => [],
      'maintenance' => Restitution::Maintenance::METRIQUES.keys,
      'livraison' => Restitution::Livraison::METRIQUES.keys,
      'objets_trouves' => Restitution::ObjetsTrouves::METRIQUES.keys
    }
    evaluations = Evaluation.joins(campagne: :compte).where(comptes: { role: :organisation })
    puts "Nombre d'évaluation : #{evaluations.count}"
    entete_colonnes = 'campagne;nom evalué·e;date creation de la partie;'
    colonnes.each_key do |mes|
      entete_colonnes += noms_colonnes(mes, colonnes, colonnes_z)
    end
    puts entete_colonnes
    evaluations.each do |e|
      situations = {}
      colonnes.each_key do |mes|
        situations[mes] = Array.new(colonnes[mes].count + colonnes_z[mes].count, 'vide')
      end

      Partie.where(evaluation: e).order(:created_at).each do |partie|
        restitution = FabriqueRestitution.instancie partie.id
        next unless restitution.termine?

        situations[partie.situation.nom_technique] = []
        case partie.situation.nom_technique
        when 'bienvenue'
          restitution.questions_et_reponses.each do |question, reponse|
            situations[partie.situation.nom_technique] << question.libelle
            reponse = question.type_qcm == :jauge.to_s ? reponse.position : reponse.intitule
            situations[partie.situation.nom_technique] << reponse
          end
        else
          colonnes[partie.situation.nom_technique]&.each do |metrique|
            valeur = partie.metriques[metrique]&.to_s || restitution.send(metrique)&.to_s
            situations[partie.situation.nom_technique] << (valeur || 'vide')
          end
          colonnes_z[partie.situation.nom_technique]&.each do |metrique|
            valeur = restitution.cote_z_metriques[metrique]
            situations[partie.situation.nom_technique] << (valeur || 'vide')
          end
        end
      end

      valeurs_des_parties = situations.keys.map do |situation|
        situations[situation].join('; ')
      end
      puts "#{e.campagne&.libelle};#{e.nom};#{e.created_at};" + valeurs_des_parties.join('; ')
    end
  end
end

class RakeLogger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
