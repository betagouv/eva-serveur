# frozen_string_literal: true

class BadgeProfilComponent < ViewComponent::Base
  TYPES = %i[acquis non_acquis].freeze

  def initialize(type)
    @type = type

    validation
  end

  private

  def validation
    return if TYPES.include? @type.to_sym

    valeurs = TYPES.join(', ')
    raise "Le type #{@type} est invalide pour BadgeProfilComponent. Valeurs possible : #{valeurs}"
  end
end
