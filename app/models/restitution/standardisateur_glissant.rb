# frozen_string_literal: true

module Restitution
  class StandardisateurGlissant < Standardisateur
    STANDARDS = {
      temps_moyen_recherche_zones_dangers: { average: 17.83, stddev_pop: 9.46 }
    }.freeze

    def initialize(metriques, collect_metriques, standards_figes = STANDARDS)
      @metriques = metriques
      @collect_metriques = collect_metriques
      @standards_figes = standards_figes
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
      aggrege_metrique(:average, metrique)
    end

    def ecart_type_metrique(metrique)
      aggrege_metrique(:stddev_pop, metrique)
    end

    def aggrege_metrique(fonction, metrique)
      return @standards_figes[metrique.to_sym][fonction] if @standards_figes.key?(metrique.to_sym)

      @collect_metriques
        .call
        .where.not(metriques: {})
        .calculate(fonction, "(metriques ->> '#{metrique}')::numeric")
        .to_f
    end
  end
end
