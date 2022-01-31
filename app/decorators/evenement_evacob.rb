# frozen_string_literal: true

class EvenementEvacob < SimpleDelegator
  def metacompetence
    'toutes'
  end

  def bonne_reponse?
    donnees['succes']
  end
end
