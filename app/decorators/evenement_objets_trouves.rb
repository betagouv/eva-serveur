# frozen_string_literal: true

class EvenementObjetsTrouves < SimpleDelegator
  def metacompetence
    donnees['metacompetence']
  end

  def bonne_reponse?
    donnees['succes']
  end
end
