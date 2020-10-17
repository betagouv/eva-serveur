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

  def tout_evenements_par_session(situation)
    sessions_ids = Partie.joins(:situation)
                         .where(situations: { nom_technique: situation})
                         .select(:session_id)
    evenements = Evenement.where(nom: :affichageQuestionQCM)
                          .or(Evenement.where(nom: :reponse))
                          .or(Evenement.where(nom: :apparitionMot))
                          .or(Evenement.where(nom: :identificationMot))
                          .or(Evenement.where(nom: :finSituation))
                          .where(session_id: sessions_ids)
                          .order(:date)
                          .each_with_object({}) do |evenement, map|
      map[evenement.session_id] ||= []
      map[evenement.session_id] << evenement
    end
  end

  def affiche_reponses_maintenance
    evenements = tout_evenements_par_session(:maintenance)
    evenements.each_key do |session_id|
      evenements_partie = evenements[session_id]
      evenementFin = evenements_partie.pop
      next unless evenementFin.nom == 'finSituation'

      evenements_partie.each_slice(2) do |apparition, identification|
        next if identification.nil?

        reponse_pasfrancais = identification.donnees['reponse'] == 'pasfrancais'
        type_non_mot = identification.donnees['type'] == 'non-mot'
        succes = (reponse_pasfrancais == type_non_mot)
        temps = identification.date - apparition.date
        puts "#{apparition.session_id};maintenance;ccf;#{identification.donnees['mot']};#{succes};#{temps}"
      end
    end
  end

  def affiche_reponses_livraison
    evenements = tout_evenements_par_session(:livraison)
    evenements.each_key do |session_id|
      evenements_partie = evenements[session_id]
      evenementFin = evenements_partie.pop
      next unless evenementFin.nom == 'finSituation'

      evenements_partie.pop ## supprime la note de rédaction

      evenements_partie.each_slice(2) do |affichage, reponse|
        next if reponse.nil?
        next if reponse.donnees['reponse'].blank?

        question = Question.find(reponse.donnees['question'])
        metacompetence = question.metacompetence
        question = question.libelle
        choix = Choix.find(reponse.donnees['reponse'])
        succes = choix.type_choix == 'bon'
        temps = reponse.date - affichage.date
        puts "#{session_id};livraison;#{metacompetence};#{question};#{succes};#{temps}"
      end
    end
  end

  def affiche_reponses_objets_trouves
    evenements = tout_evenements_par_session(:objets_trouves)
    evenements.each_key do |session_id|
      evenements_partie = evenements[session_id]
      evenementFin = evenements_partie.pop
      next unless evenementFin.nom == 'finSituation'

      evenements_partie.each_slice(2) do |affichage, reponse|
        next if reponse.nil?

        valeurs = "#{reponse.donnees['metacompetence']};#{reponse.donnees['question']}"
        reponse = "#{reponse.donnees['succes']};#{reponse.date - affichage.date}"
        puts "#{session_id};objets_trouves;#{valeurs};#{reponse}"
      end
    end
  end

  desc 'Extrait les données des questions'
  task questions: :environment do
    Rails.logger.level = :warn

    puts 'identifiant évaluation;MES;meta-competence;question;succes;temps de reponse'
    affiche_reponses_maintenance
    affiche_reponses_livraison
    affiche_reponses_objets_trouves
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

  desc 'Extrait les données pour la bascule vers un algorithme figé'
  task stats_niveau1: :environment do
    evaluations = Evaluation.joins(campagne: :compte).where(comptes: { role: :organisation })
    puts "Nombre d'évaluation : #{evaluations.count}"
    entete_colonnes = 'campagne;nom evalué·e;date creation de la partie;litteratie_z;numeratie_z'
    puts entete_colonnes
    evaluations.each do |e|
      rg = FabriqueRestitution.restitution_globale(e)
      scores = rg.scores_niveau1_standardises.calcule
      puts "#{e.campagne&.libelle};#{e.nom};#{e.created_at};#{scores.values.join('; ')}"
    end
  end
end

class RakeLogger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
