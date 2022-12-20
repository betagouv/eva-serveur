# frozen_string_literal: true

class PriseEnMain
  ETAPES = %w[campagne_creee campagne_testee retour_effectue].freeze

  def initialize(compte:, nombre_campagnes:, nombre_evaluations:)
    @compte = compte
    @nombre_campagnes = nombre_campagnes
    @nombre_evaluations = nombre_evaluations
  end

  def numero_etape
    return 0 if @nombre_campagnes.zero?
    return 1 if @nombre_evaluations.zero?

    2
  end

  def terminee?
    !@compte.nouveau_compte? && @nombre_evaluations > 1
  end

  def en_cours?
    !terminee?
  end
end
