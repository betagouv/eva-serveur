# frozen_string_literal: true

class EvenementEvacob < SimpleDelegator
  PREFIX_QUESTIONS = {
    orientation: 'LOdi'
  }.freeze

  def metacompetence
    'toutes'
  end

  def bonne_reponse?
    donnees['succes']
  end

  def parcours?(parcours)
    donnees['question'].start_with?(PREFIX_QUESTIONS[parcours])
  end

  def score_reponse
    donnees['score']
  end
end
