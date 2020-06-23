# frozen_string_literal: true

module Restitution
  class StandardisateurEchantillon
    def initialize(metriques, scores_evaluations)
      @metriques = metriques
      @scores_evaluations = scores_evaluations
    end

    def moyennes_glissantes
      @moyennes_glissantes ||= @metriques.each_with_object({}) do |metrique, memo|
        memo[metrique] = moyenne_metrique(metrique)
      end
    end

    def ecarts_types_glissants
      @ecarts_types_glissants ||= @metriques.each_with_object({}) do |metrique, memo|
        memo[metrique] = ecart_type_metrique(metrique)
      end
    end

    def standardise(metrique, valeur)
      return if valeur.nil? || ecart_type_metriques[metrique].nil?

      if ecart_type_metriques[metrique].zero?
        0
      else
        (
          (valeur - moyenne_metriques[metrique]) / ecart_type_metriques[metrique]
        )
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
