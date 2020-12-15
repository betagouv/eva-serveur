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

  def sessions_ids(situation)
    Partie.joins(:situation)
          .where(situations: { nom_technique: situation })
          .select(:session_id)

    # Partie.joins(:situation).joins(:evaluation)
    #  .where(situations: { nom_technique: situation },
    #         evaluations: {campagne_id: 'c6a094ff-b77e-49cb-9020-58a110933cda' }) ## Mayotte
    #         #evaluations: {campagne_id: '7ee72648-45af-4470-8faf-f8a66e56da1d' }) ## Guyane
    #  .select(:session_id)
  end

  def tout_evenements_par_session(situation)
    Evenement.where(nom: :affichageQuestionQCM)
             .or(Evenement.where(nom: :reponse))
             .or(Evenement.where(nom: :apparitionMot))
             .or(Evenement.where(nom: :identificationMot))
             .or(Evenement.where(nom: :finSituation))
             .where(session_id: sessions_ids(situation))
             .order(:date)
             .each_with_object({}) do |evenement, map|
      map[evenement.session_id] ||= []
      map[evenement.session_id] << evenement
    end
  end

  def visite_reponses(situation)
    evenements = tout_evenements_par_session(situation)
    evenements.each_key do |session_id|
      evenements_partie = evenements[session_id]
      evenement_fin = evenements_partie.pop
      next unless evenement_fin.nom == 'finSituation'

      identification = "#{evenements_partie.first.partie.evaluation_id};#{session_id}"
      evenements_partie.pop if situation == :livraison ## supprime la note de rédaction
      evenements_partie.each_slice(2) do |affichage, reponse|
        next if reponse.nil?

        yield(identification, reponse, reponse.date - affichage.date)
      end
    end
  end

  def affiche_reponses_maintenance
    visite_reponses(:maintenance) do |identification, reponse, temps|
      reponse_pasfrancais = reponse.donnees['reponse'] == 'pasfrancais'
      type_non_mot = reponse.donnees['type'] == 'non-mot'
      succes = (reponse_pasfrancais == type_non_mot)
      valeurs = "#{succes};#{temps}"
      puts "#{identification};maintenance;ccf;#{reponse.donnees['mot']};#{valeurs}"
    end
  end

  def affiche_reponses_livraison
    visite_reponses(:livraison) do |identification, reponse, temps|
      next if reponse.donnees['reponse'].blank?

      question = Question.find(reponse.donnees['question'])

      metacompetence = question.metacompetence
      libelle = question.libelle
      question_reponse = [question.intitule]
      if libelle != 'Communication écrite'
        choix = Choix.find(reponse.donnees['reponse'])
        succes = choix.type_choix == 'bon'
        question_reponse << "\"#{choix.intitule}\""
      end
      puts "#{identification};livraison;#{metacompetence};#{libelle};#{succes};#{temps};#{question_reponse.join(';')}"
    end
  end

  def affiche_reponses_objets_trouves
    visite_reponses(:objets_trouves) do |identification, reponse, temps|
      valeurs = "#{reponse.donnees['metacompetence']};#{reponse.donnees['question']}"
      donnees_reponse = "#{reponse.donnees['succes']};#{temps};#{reponse.donnees['reponse']}"
      puts "#{identification};objets_trouves;#{valeurs};#{donnees_reponse}"
    end
  end

  desc 'Extrait les données des questions'
  task questions: :environment do
    Rails.logger.level = :warn

    puts 'évaluation;partie;MES;meta-competence;question;succes;temps de reponse'
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
    # evaluations = Evaluation.joins(campagne: :compte).where(comptes: { role: :organisation }, campagnes: { id: 'c6a094ff-b77e-49cb-9020-58a110933cda'}) ## SMA mayotte
    # evaluations = Evaluation.joins(campagne: :compte).where(comptes: { role: :organisation }, campagnes: { id: '7ee72648-45af-4470-8faf-f8a66e56da1d' }) ## SMA Guyane
    puts "Nombre d'évaluation : #{evaluations.count}"
    entete_colonnes = 'id eva;campagne;nom evalué·e;date creation de la partie;litteratie_z;numeratie_z;score_ccf;score_syntaxe_orthographe;score_memorisation;score_numeratie'
    puts entete_colonnes
    evaluations.each do |e|
      rg = FabriqueRestitution.restitution_globale(e)
      scores = rg.scores_niveau1_standardises.calcule
      scores_metacompetence = rg.scores_niveau2_standardises.calcule
      colonnes = [
        e.id,
        e.campagne&.libelle, e.nom, e.created_at,
        scores.values.join(';'),
        rg.interpreteur_niveau1.synthese,
        %i[score_ccf score_syntaxe_orthographe score_memorisation score_numeratie].map do |score|
          scores_metacompetence[score]
        end.join(';')
      ]
      puts colonnes.join(';')
    end
  end
end

class RakeLogger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
