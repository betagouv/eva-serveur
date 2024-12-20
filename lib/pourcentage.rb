# frozen_string_literal: true

class Pourcentage
  def initialize(valeur:, valeur_max:)
    @valeur = valeur
    @valeur_max = valeur_max
  end

  # retourne un pourcentage (float) ou nil
  def calcul
    return if @valeur.blank?
    return if @valeur_max.blank?
    return if @valeur_max.zero?

    (@valeur.to_f / @valeur_max) * 100
  end
end
