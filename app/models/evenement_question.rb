# frozen_string_literal: true

class EvenementQuestion # rubocop:disable Metrics/ClassLength
  def initialize(question:, evenement: nil)
    @evenement = evenement || Evenement.new(donnees: {})
    @question = question || Question.new(nom_technique: evenement.donnees['question'])
  end

  def score
    @evenement.donnees['score'] || 0
  end

  def score_max
    @evenement.donnees['scoreMax'] || @question.score
  end

  def succes
    @evenement.donnees['succes'] || false
  end

  def reponse
    @evenement.donnees['reponseIntitule'] || @evenement.donnees['reponse']
  end

  def reponses_possibles
    @question&.interaction == 'qcm' ? @question&.liste_choix : nil
  end

  def reponses_attendues
    @question&.qcm? || @question&.saisie? ? @question&.bonnes_reponses : nil
  end

  def intitule
    @evenement.donnees['intitule'] || @question.transcription_intitule&.ecrit
  end

  def metacompetence
    @evenement.donnees['metacompetence'] || @question.metacompetence
  end

  def a_ete_repondue?
    @evenement.persisted? && score.present?
  end

  def est_principale?
    @question.est_principale?
  end

  def est_un_rattrapage?
    @question.est_un_rattrapage?
  end

  def interaction
    @question.interaction
  end

  def code_clea
    Metacompetence.new(metacompetence).code_clea_sous_sous_domaine
  end

  def nom_technique
    @question.nom_technique
  end

  def pris_en_compte_pour_calcul_score_clea?(questions)
    questions.any? { |q| q.nom_technique == nom_technique }
  end

  def self.pourcentage_pour_groupe(evenements_questions)
    scores = evenements_questions.map do |evenement_question|
      next if evenement_question.score_max.nil?

      [evenement_question.score_max, evenement_question.score]
    end.compact
    score_max, score = scores.transpose.map(&:sum)
    Pourcentage.new(valeur: score, valeur_max: score_max).calcul&.round
  end

  def self.score_max_pour_groupe(evenements_questions)
    evenements_questions.map(&:score_max).compact.sum
  end

  def self.score_pour_groupe(evenements_questions)
    evenements_questions.map(&:score).sum
  end

  def self.filtre_pris_en_compte(evenements_questions, evenements_questions_a_prendre_en_compte)
    evenements_questions.select do |evenement_question|
      evenements_questions_a_prendre_en_compte
        .map(&:nom_technique).include? evenement_question.nom_technique
    end
  end

  def self.pour_code_clea(evenements_questions, code)
    metacompetences = Metacompetence.metacompetences_pour_code(code)
    evenements_questions.select do |evenement_question|
      metacompetences.include? evenement_question.metacompetence
    end
  end

  def self.prises_en_compte_pour_calcul_score_clea(evenements_questions)
    resultat = evenements_questions.flatten
    dernier_niveau_joue = dernier_niveau_joue(resultat)

    return resultat if dernier_niveau_joue.nil?

    resultat = exclure_niveaux_superieurs(resultat, dernier_niveau_joue)
    groupes_clea = regrouper_par_critere_clea(resultat)

    selectionner_questions_a_prendre(groupes_clea)
  end

  def self.dernier_niveau_joue(evenements_questions)
    niveaux_joues = evenements_questions
                    .select(&:a_ete_repondue?)
                    .map { |eq| eq.nom_technique.match(/^N(\d)/)&.captures&.first.to_i }
                    .compact
                    .uniq
    niveaux_joues.max || 1
  end

  def self.exclure_niveaux_superieurs(evenements_questions, dernier_niveau_joue)
    evenements_questions.reject do |eq|
      niveau_question = eq.nom_technique.match(/N(\d)/)&.captures&.first.to_i
      niveau_question > dernier_niveau_joue
    end
  end

  def self.regrouper_par_critere_clea(evenements_questions)
    evenements_questions.group_by(&:code_clea)
  end

  def self.selectionner_questions_a_prendre(groupes_clea) # rubocop:disable all
    questions_a_prendre = []

    groupes_clea.each_value do |questions|
      questions_principales = questions.select(&:est_principale?)
      questions_rattrapage = questions.reject(&:est_principale?)

      questions_principales.each do |question_principale|
        questions_a_prendre << question_principale
        question_rattrapage = questions_rattrapage.find do |q|
          q.nom_technique.gsub(/^N(\d)R/, 'N\\1P') == question_principale.nom_technique
        end
        next unless question_rattrapage

        if doit_prendre_en_compte_rattrapage?(question_principale, question_rattrapage)
          questions_a_prendre << question_rattrapage
        end
      end
    end

    questions_a_prendre
  end

  def self.doit_prendre_en_compte_rattrapage?(question_principale, question_rattrapage)
    return false unless question_principale.a_ete_repondue?
    return false if question_principale.score.positive?
    return false if question_principale.score >= question_rattrapage.score_max

    true
  end
end
