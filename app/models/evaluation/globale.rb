# frozen_string_literal: true

module Evaluation
  class Globale
    attr_reader :evaluations

    def initialize(evaluations:)
      @evaluations = evaluations
    end

    def utilisateur
      evaluations.first.utilisateur
    end

    def date
      evaluations.first.date
    end

    def efficience
      return nil if evaluations.blank?

      efficiences = evaluations.collect(&:efficience).compact
      efficiences.inject(0.0) { |somme, efficience| somme + efficience } / efficiences.size
    end
  end
end
