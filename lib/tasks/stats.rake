namespace :stats do
  desc "Extrait les données pour la bascule vers un algorithme figé"
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
        scores.values.join(";"),
        rg.interpreteur_niveau1.synthese,
        %i[score_ccf score_syntaxe_orthographe score_memorisation score_numeratie].map do |score|
          scores_metacompetence[score]
        end.join(";"),
        structure&.type_structure
      ]
      puts colonnes.join(";")
    end
  end

  def entete_colonnes
    [
      "id eva", "campagne", "date creation de la partie", "litteratie_z", "numeratie_z",
      "synthese illettrisme", "score_ccf", "score_syntaxe_orthographe", "score_memorisation",
      "score_numeratie", "type de structure"
    ].join(";")
  end

  def recupere_evaluations
    Evaluation.includes(
      campagne: [ :situations_configurations, { compte: :structure } ]
    ).where.not(comptes: { role: :superadmin })
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
             .each_with_object({}) do |evenement, map|
      # attention, find_each ne fonctionne pas avec order
      map[evenement.session_id] ||= []
      map[evenement.session_id] << evenement
    end
  end

  def visite_evenements_partie(situation, evenements_partie)
    evenement_fin = evenements_partie.pop
    return unless evenement_fin.nom == "finSituation"

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
      reponse_pasfrancais = reponse.donnees["reponse"] == "pasfrancais"
      type_non_mot = reponse.donnees["type"] == "non-mot"
      succes = (reponse_pasfrancais == type_non_mot)
      valeurs = "#{succes};#{temps}"
      puts "#{identification};maintenance;ccf;#{reponse.donnees['mot']};#{valeurs}"
    end
  end

  def visite_reponses_livraison
    visite_reponses(:livraison) do |identification, reponse, temps|
      next if reponse.donnees["reponse"].blank?

      question = Question.find(reponse.donnees["question"])
      libelle = question.libelle
      if libelle != "Communication écrite"
        reponse = reponse.donnees["reponse"]
        choix = Choix.find(reponse)
      end
      yield(identification, question, libelle, choix, temps)
    end
  end

  def affiche_reponses_livraison
    visite_reponses_livraison do |identification, question, libelle, choix, temps|
      metacompetence = question.metacompetence
      question_reponse = [ question.transcription_intitule&.ecrit ]
      if choix.present?
        succes = choix.type_choix == "bon"
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

  desc "Extrait les données des questions"
  task questions: :environment do
    puts "évaluation;partie;campagne;MES;meta-competence;question;succes;temps de reponse"
    affiche_reponses_maintenance
    affiche_reponses_livraison
    affiche_reponses_objets_trouves
  end

  def noms_colonnes(mes, colonnes, colonnes_z)
    noms = ""
    noms += "#{mes}: #{colonnes[mes].join("; #{mes}: ")};" unless colonnes[mes].empty?
    unless colonnes_z[mes].empty?
      noms += "#{mes}: cote_z_#{colonnes_z[mes].join("; #{mes}: cote_z_")};"
    end
    noms
  end

  def print_entete_colonnes(colonnes, colonnes_z)
    entete_colonnes = "evaluation;date creation;"
    colonnes.each_key do |mes|
      entete_colonnes += noms_colonnes(mes, colonnes, colonnes_z)
    end
    puts entete_colonnes
  end

  def lit_valeurs_colonne(valeurs, colonnes)
    colonnes&.each do |colonne|
      valeurs << (yield(colonne) || "vide")
    end
  end

  def lit_valeurs_colonnes(partie, restitution, colonnes, colonnes_z)
    valeurs = []
    lit_valeurs_colonne(valeurs, colonnes) do |colonne|
      partie.metriques[colonne]&.to_s || restitution.send(colonne)&.to_s
    end
    lit_valeurs_colonne(valeurs, colonnes_z) do |colonne|
      restitution.cote_z_metriques[colonne]
    end
    valeurs
  end

  def visite_parties(evaluation, situations)
    Partie.where(evaluation: evaluation).order(:created_at).each do |partie|
      situation = partie.situation.nom_technique
      next unless situations.include?(situation)

      restitution = FabriqueRestitution.instancie partie
      next unless restitution.termine?

      yield(situation, partie, restitution)
    end
  end

  def collecte_donnees(evaluation, colonnes, colonnes_z)
    situations = {}
    colonnes.each_key do |mes|
      situations[mes] = Array.new(colonnes[mes].count + colonnes_z[mes].count, "vide")
    end

    visite_parties(evaluation, colonnes.keys) do |situation, partie, restitution|
      situations[situation] =
        lit_valeurs_colonnes(partie, restitution,
                             colonnes[situation], colonnes_z[situation])
    end
    situations
  end

  desc "Extrait les données de tri, inventaire et securité"
  task competences_transversales: :environment do
    Rails.logger.level = :warn
    colonnes = {
      "tri" => %i[nombre_bien_placees nombre_mal_placees temps_total],
      "inventaire" => %i[nombre_ouverture_contenant nombre_essais_validation temps_total],
      "controle" => %i[nombre_bien_placees nombre_mal_placees nombre_non_triees temps_total],
      "securite" => Restitution::Securite::METRIQUES.keys
    }
    colonnes_z = {
      "tri" => [],
      "inventaire" => [],
      "controle" => [],
      "securite" => Restitution::Securite::METRIQUES.keys
    }
    evaluations = recupere_evaluations
    puts "Nombre d'évaluation : #{evaluations.count}"
    print_entete_colonnes(colonnes, colonnes_z)
    evaluations.each do |e|
      situations = collecte_donnees(e, colonnes, colonnes_z)

      valeurs_des_parties = situations.keys.map do |situation|
        situations[situation].join("; ")
      end
      puts "#{e.id};#{e.created_at};" + valeurs_des_parties.join("; ")
    end
  end

  desc "calcule les temps max, min et moyens des évaluations d'une campagne"
  task temps_moyens_campagne: :environment do
    arg_campagne = "CAMPAGNE"
    logger = RakeLogger.logger
    unless ENV.key?(arg_campagne)
      logger.error "La variable d'environnement #{arg_campagne} est manquante"
      logger.info "Usage : rake stats:temps_moyens_campagne CAMPAGNE=id_campagne"
      next
    end
    campagne = Campagne.find(ENV.fetch(arg_campagne))
    statistiques = StatistiquesCampagne.new(campagne)
    helper = Class.new.extend(ApplicationHelper)
    min = helper.formate_duree statistiques.temps_min
    max = helper.formate_duree statistiques.temps_max
    moyenne = helper.formate_duree statistiques.temps_moyen
    puts "id_campagne;temps_min;temps_max;temps_moyen"
    puts "#{ENV.fetch(arg_campagne)};#{min};#{max};#{moyenne}"
  end
end
