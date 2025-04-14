# frozen_string_literal: true

class EvenementLivraison < SimpleDelegator
  def metacompetence
    question&.metacompetence
  end

  def question
    @question ||= Question.find_by id: donnees["question"]
  end

  def bonne_reponse?
    choix&.bon?
  end

  def choix
    @choix ||= question.choix.find_by(id: donnees["reponse"])
  end
end
