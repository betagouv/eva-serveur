# frozen_string_literal: true

namespace :stats do
  desc 'Extrait les données pour la bascule vers un algorithme figé'
  task niveau_1_et2: :environment do
    evaluations = recupere_evaluations
    puts "Nombre d'évaluation : #{evaluations.count}"
    puts entete_colonnes
    evaluations.each do |e|
      rg = FabriqueRestitution.restitution_globale(e)
      scores = rg.scores_niveau1_standardises.calcule
      scores_metacompetence = rg.scores_niveau2_standardises.calcule
      campagne = e.campagne
      structure = campagne&.compte&.structure
      colonnes = [
        e.id,
        campagne&.code, e.created_at,
        scores.values.join(';'),
        rg.interpreteur_niveau1.synthese,
        %i[score_ccf score_syntaxe_orthographe score_memorisation score_numeratie].map do |score|
          scores_metacompetence[score]
        end.join(';'),
        structure&.type_structure
      ]
      puts colonnes.join(';')
    end
  end

  def entete_colonnes
    [
      'id eva', 'campagne', 'date creation de la partie', 'litteratie_z', 'numeratie_z',
      'synthese illettrisme', 'score_ccf', 'score_syntaxe_orthographe', 'score_memorisation',
      'score_numeratie', 'type de structure'
    ].join(';')
  end

  def recupere_evaluations
    Evaluation.includes(
      campagne: [:situations_configurations, { compte: :structure }]
    ).where(comptes: { role: :organisation })
  end

  def sessions_ids(situation)
    Partie.joins(:situation)
          .where(situations: { nom_technique: situation })
          .select(:session_id)
  end

  def tout_evenements_par_session(situation)
    Evenement.where(
      nom: %i[affichageQuestionQCM reponse apparitionMot identificationMot finSituation],
      session_id: sessions_ids(situation)
    )
             .order(:date)
             .find_each.with_object({}) do |evenement, map|
      map[evenement.session_id] ||= []
      map[evenement.session_id] << evenement
    end
  end

  def visite_evenements_partie(situation, evenements_partie)
    evenement_fin = evenements_partie.pop
    return unless evenement_fin.nom == 'finSituation'

    evenements_partie.pop if situation == :livraison ## supprime la note de rédaction
    evenements_partie.each_slice(2) do |affichage, reponse|
      next if reponse.nil?

      yield(reponse, reponse.date - affichage.date)
    end
  end

  def visite_reponses(situation)
    evenements = tout_evenements_par_session(situation)
    evenements.each_key do |session_id|
      evenements_partie = evenements[session_id]

      partie = evenements_partie.first.partie
      identification = "#{partie.evaluation_id};#{session_id};#{partie.evaluation.campagne.code}"
      visite_evenements_partie(situation, evenements_partie) do |reponse, temps|
        yield(identification, reponse, temps)
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

  def visite_reponses_livraison
    visite_reponses(:livraison) do |identification, reponse, temps|
      next if reponse.donnees['reponse'].blank?

      question = Question.find(reponse.donnees['question'])
      libelle = question.libelle
      if libelle != 'Communication écrite'
        reponse = reponse.donnees['reponse']
        choix = Choix.find(reponse)
      end
      yield(identification, question, libelle, choix, temps)
    end
  end

  def affiche_reponses_livraison
    visite_reponses_livraison do |identification, question, libelle, choix, temps|
      metacompetence = question.metacompetence
      question_reponse = [question.intitule]
      if choix.present?
        succes = choix.type_choix == 'bon'
        question_reponse << "\"#{choix.intitule}\""
      end
      colonnes_question = "#{identification};livraison;#{metacompetence};#{libelle}"
      puts "#{colonnes_question};#{succes};#{temps};#{question_reponse.join(';')}"
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
    puts 'évaluation;partie;campagne;MES;meta-competence;question;succes;temps de reponse'
    affiche_reponses_maintenance
    affiche_reponses_livraison
    affiche_reponses_objets_trouves
  end
end
