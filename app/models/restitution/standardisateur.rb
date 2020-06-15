# frozen_string_literal: true

module Restitution
  class Standardisateur
    def initialize(metriques, collect_metriques)
      @metriques = metriques
      @collect_metriques = collect_metriques
    end

    def moyenne_metrique(metrique)
      aggrege_metrique(:average, metrique)
    end

    def ecart_type_metrique(metrique)
      aggrege_metrique(:stddev_pop, metrique)
    end

    def moyenne_metriques
      @moyenne_metriques ||= @metriques.each_with_object({}) do |metrique, memo|
        memo[metrique] = moyenne_metrique(metrique)
      end
    end

    def ecart_type_metriques
      @ecart_type_metriques ||= @metriques.each_with_object({}) do |metrique, memo|
        memo[metrique] = ecart_type_metrique(metrique)
      end
    end

    def standardise(metrique, valeur)
      return if valeur.nil?

      if ecart_type_metriques[metrique].zero?
        0
      else
        (
          (valeur - moyenne_metriques[metrique]) / ecart_type_metriques[metrique]
        )
      end
    end

    private

    def aggrege_metrique(fonction, metrique)
      @collect_metriques
        .call
        .where.not(metriques: {})
        .calculate(fonction, "(metriques ->> '#{metrique}')::numeric")
        .to_f
    end
  end
end
