# frozen_string_literal: true

class PriseEnMain
  ETAPES = %w[rejoindre_structure creation_campagne test_campagne confirmation_email passations
              fin].freeze

  def initialize(compte:, nombre_campagnes:, nombre_evaluations:)
    @compte = compte
    @nombre_campagnes = nombre_campagnes
    @nombre_evaluations = nombre_evaluations
  end

  def etape_en_cours
    return "rejoindre_structure" if @compte.structure.nil?
    return "creation_campagne" if @nombre_campagnes.zero?
    return "test_campagne" if @nombre_evaluations.zero?
    return "confirmation_email" unless @compte.confirmed?
    return "passations" if @nombre_evaluations < 4

    "fin"
  end

  def terminee?
    !en_cours?
  end

  def en_cours?
    @compte.mode_tutoriel? || @compte.structure.blank?
  end

  def nombre_passations_restantes
    4 - @nombre_evaluations
  end
end
