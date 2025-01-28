# frozen_string_literal: true

class EvenementQuestion
  def initialize(question:, evenement: nil)
    @evenement = evenement || Evenement.new(donnees: {})
    @question = question
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
    questions.any? { |q| q.nom_technique == @question.nom_technique }
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
end
