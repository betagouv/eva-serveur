# frozen_string_literal: true

class PriseEnMain
  ETAPES = %w[creation_campagne test_campagne passations retour_experience].freeze

  def initialize(compte:, nombre_campagnes:, nombre_evaluations:)
    @compte = compte
    @nombre_campagnes = nombre_campagnes
    @nombre_evaluations = nombre_evaluations
  end

  def etape_en_cours
    return 'creation_campagne' if @nombre_campagnes.zero?
    return 'test_campagne' if @nombre_evaluations.zero?
    return 'passations' if @nombre_evaluations < 4

    'retour_experience'
  end

  def terminee?
    !@compte.nouveau_compte? && @nombre_evaluations >= 4
  end

  def en_cours?
    !terminee?
  end

  def nombre_passations_restantes
    4 - @nombre_evaluations
  end
end
