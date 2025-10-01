module Restitution
  class StandardisateurGlissant < Standardisateur
    def initialize(metriques, collect_metriques, standards_figes = nil)
      super()
      @metriques = metriques
      @collect_metriques = collect_metriques
      @standards_figes = standards_figes
    end

    def moyennes_metriques
      @moyennes_metriques ||= @metriques.index_with do |metrique|
        moyenne_metrique(metrique)
      end
    end

    def ecarts_types_metriques
      @ecarts_types_metriques ||= @metriques.index_with do |metrique|
        ecart_type_metrique(metrique)
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
      return @standards_figes[metrique.to_sym][fonction] if @standards_figes&.key?(metrique.to_sym)

      @collect_metriques
        .call
        .where.not(metriques: {})
        .calculate(fonction, "(metriques ->> '#{metrique}')::numeric")
        .to_f
    end
  end
end
