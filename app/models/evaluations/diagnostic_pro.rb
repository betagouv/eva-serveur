# frozen_string_literal: true

module Evaluations
  class DiagnosticPro
    attr_reader :evaluation

    def initialize(evaluation)
      @evaluation = evaluation
    end

    def evapro?
      true
    end

    def opco_financeur
      structure = evaluation.campagne&.compte&.structure
      return if structure.blank?

      structure.opco_financeur
    end

    def opco
      structure = evaluation.campagne&.compte&.structure
      return if structure.blank?

      structure.opco
    end

    def with_restitution_globale(restitution_globale)
      Restitution.new(restitution_globale: restitution_globale)
    end

    def titre
      evaluation.structure&.nom
    end
  end
end
