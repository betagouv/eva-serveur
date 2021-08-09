# frozen_string_literal: true

class PriseEnMain
  def initialize(compte:, nombre_campagnes:, nombre_evaluations:)
    @compte = compte
    @nombre_campagnes = nombre_campagnes
    @nombre_evaluations = nombre_evaluations
  end

  def numero_etape
    @nombre_campagnes.zero? ? 0 : 1
  end

  def terminee?
    !@compte.nouveau_compte? && @nombre_evaluations.positive?
  end
end
