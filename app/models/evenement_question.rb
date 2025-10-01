class EvenementQuestion
  def initialize(question:, evenement: nil)
    @evenement = evenement || Evenement.new(donnees: {})
    @question = question || Question.new(nom_technique: evenement.donnees["question"])
  end

  delegate :est_principale?, :est_un_rattrapage?, :nom_technique, :bonnes_reponses,
           :reponses_possibles, to: :@question
  delegate :fin_situation?, to: :@evenement

  def score
    @evenement.donnees["score"] || 0
  end

  def score_max
    @evenement.donnees["scoreMax"] || @question.score
  end

  def succes
    @evenement.donnees["succes"] || false
  end

  def reponse
    @evenement.donnees["reponseIntitule"].presence ||
      @question.intitule_reponse(@evenement.donnees["reponse"])
  end

  def intitule
    @evenement.donnees["intitule"] || @question.transcription_intitule&.ecrit
  end

  def metacompetence
    @evenement.donnees["metacompetence"] || @question.metacompetence
  end

  def a_ete_repondue?
    @evenement.persisted? && score.present?
  end

  def type_question
    @question.type
  end

  def code_clea
    Metacompetence.code_clea_sous_sous_domaine(metacompetence)
  end

  def pris_en_compte_pour_calcul_score_clea?(questions)
    questions.any? { |q| q.nom_technique == nom_technique }
  end

  class << self
    ##
    # Passer l'ensemble des questions de la situation d'une campagne
    # Ex : campagne.questionnaire_pour(situation).questions
    # Passer l'ensemble des evenements de la partie
    def construit_pour(evenements, questions)
      evenements = evenements.select(&:reponse?)
      questions = questions.to_a.reject do |question|
        question.type == QuestionSousConsigne::QUESTION_TYPE
      end

      questions.map do |question|
        evenement = evenements.find do |e|
          e.question_nom_technique == question.nom_technique_sans_variant
        end
        EvenementQuestion.new(question: question, evenement: evenement)
      end
    end

    def pourcentage_pour_groupe(evenements_questions)
      scores = evenements_questions.map { |eq| [ eq.score_max.presence || 0, eq.score ] }.compact
      score_max, score = scores.transpose.map(&:sum)
      Pourcentage.new(valeur: score, valeur_max: score_max).calcul&.round
    end

    def score_max_pour_groupe(evenements_questions)
      evenements_questions.map(&:score_max).compact.sum
    end

    def score_pour_groupe(evenements_questions)
      evenements_questions.map(&:score).sum
    end

    def filtre_pris_en_compte(evenements_questions, questions_a_prendre)
      evenements_questions.select do |eq|
        questions_a_prendre.map(&:nom_technique).include?(eq.nom_technique)
      end
    end

    def pour_code_clea(evenements_questions, code)
      metacompetences = Metacompetence.metacompetences_pour_code(code)
      evenements_questions.select { |eq| metacompetences.include?(eq.metacompetence) }
    end

    def prises_en_compte_pour_calcul_score_clea(evenements_questions)
      resultat = evenements_questions.flatten
      dernier_niveau = dernier_niveau_joue(resultat)

      return resultat if dernier_niveau.nil?

      resultat = conserver_questions_principales(resultat, dernier_niveau)
      resultat = inclure_rattrapages_si_joues(resultat)
      groupes_clea = regrouper_par_critere_clea(resultat)

      selectionner_questions_a_prendre(groupes_clea)
    end

    def dernier_niveau_joue(evenements_questions)
      niveaux_joues = evenements_questions
                      .select(&:a_ete_repondue?)
                      .map { |eq| eq.nom_technique.match(/^N(\d)/)&.captures&.first.to_i }
                      .compact
                      .uniq
      niveaux_joues.max || 1
    end

    def conserver_questions_principales(evenements_questions, dernier_niveau)
      evenements_questions.select do |eq|
        niveau = eq.nom_technique.match(/N(\d)/)&.captures&.first.to_i
        eq.est_principale? || niveau <= dernier_niveau
      end
    end

    def inclure_rattrapages_si_joues(evenements_questions)
      evenements_questions.select { |eq| !eq.est_un_rattrapage? || eq.a_ete_repondue? }
    end

    def regrouper_par_critere_clea(evenements_questions)
      evenements_questions.group_by(&:code_clea)
    end

    def selectionner_questions_a_prendre(groupes_clea)
      questions_a_prendre = []

      groupes_clea.each_value do |questions|
        questions_principales, questions_rattrapage = questions.partition(&:est_principale?)
        questions_principales.each { |q| questions_a_prendre << q }
        questions_rattrapage.each { |q| questions_a_prendre << q if q.a_ete_repondue? }
      end

      questions_a_prendre
    end
  end
end
