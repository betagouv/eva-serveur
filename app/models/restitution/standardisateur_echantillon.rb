# frozen_string_literal: true

module Restitution
  class StandardisateurEchantillon < Standardisateur
    def initialize(metriques, scores_evaluations)
      @metriques = metriques
      @scores_evaluations = scores_evaluations
    end

    def moyennes_metriques
      @moyennes_metriques ||= @metriques.each_with_object({}) do |metrique, memo|
        memo[metrique] = moyenne_metrique(metrique)
      end
    end

    def ecarts_types_metriques
      @ecarts_types_metriques ||= @metriques.each_with_object({}) do |metrique, memo|
        memo[metrique] = ecart_type_metrique(metrique)
      end
    end

    private

    def moyenne_metrique(metrique)
      return unless @scores_evaluations.key?(metrique)

      DescriptiveStatistics.mean(@scores_evaluations[metrique])
    end

    def ecart_type_metrique(metrique)
      return unless @scores_evaluations.key?(metrique)

      DescriptiveStatistics.standard_deviation(@scores_evaluations[metrique])
    end
  end
end
