# frozen_string_literal: true

class EvenementEvacob < SimpleDelegator
  PREFIX_QUESTIONS = {
    orientation: 'LO',
    lecture_complet: 'AL'
  }.freeze

  NUMEROS_QUESTION_LECTURE_ORIENTATION = [2, 4, 5].freeze

  def bonne_reponse?
    donnees['succes']
  end

  def module?(nom_module)
    return question_lecture_orientation? if nom_module == :lecture_complet && module?(:orientation)

    donnees['question'].start_with?(PREFIX_QUESTIONS[nom_module])
  end

  def score_reponse
    donnees['score'] || 0
  end

  private

  def question_lecture_orientation?
    numero_question = donnees['question'].scan(/\d+/).first.to_i
    NUMEROS_QUESTION_LECTURE_ORIENTATION.include?(numero_question)
  end
end
