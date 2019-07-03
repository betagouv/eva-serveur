# frozen_string_literal: true

module Restitution
  class Globale
    attr_reader :restitutions

    NIVEAU_INDETERMINE = :indetermine

    def initialize(restitutions:)
      @restitutions = restitutions
    end

    def utilisateur
      restitutions.first.utilisateur
    end

    def date
      restitutions.first.date
    end

    def efficience
      return 0 if restitutions.blank?

      efficiences = restitutions.collect(&:efficience).compact
      return NIVEAU_INDETERMINE if efficiences.include?(NIVEAU_INDETERMINE)

      efficiences.inject(0.0) { |somme, efficience| somme + efficience } / efficiences.size
    end
  end
end
