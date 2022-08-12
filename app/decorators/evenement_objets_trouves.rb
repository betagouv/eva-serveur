# frozen_string_literal: true

class EvenementObjetsTrouves < SimpleDelegator
  def metacompetence
    donnees['metacompetence']
  end

  def bonne_reponse?
    donnees['succes']
  end

  def question_nom_technique
    donnees['question']
  end
end
