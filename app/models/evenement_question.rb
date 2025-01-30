# frozen_string_literal: true

class EvenementQuestion
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

  def self.prises_en_compte_pour_calcul_score_clea(evenements_questions) # rubocop:disable all
    resultat = evenements_questions.flatten

    evenements_questions_groupes = evenements_questions.group_by do |evenement_question|
      evenement_question.nom_technique[0, 5]
    end

    evenements_questions_groupes.each do |nom_technique, groupe|
      next unless groupe.all? do |evenement_question|
        evenement_question.est_principale? && evenement_question.score.positive?
      end

      nom_technique_rattrapage =
        Restitution::Evacob::ScoreModule::NUMERATIE_METRIQUES[nom_technique]

      next unless nom_technique_rattrapage

      resultat.reject! do |evenement_question|
        evenement_question.nom_technique.start_with? nom_technique_rattrapage
      end
    end

    resultat
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
end
