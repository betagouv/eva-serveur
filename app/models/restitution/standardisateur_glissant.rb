module Restitution
  class StandardisateurGlissant < Standardisateur
    def initialize(metriques, collect_metriques, standards_figes = nil)
      super()
      @metriques = metriques
      @collect_metriques = collect_metriques
      @standards_figes = standards_figes
    end

    def moyennes_metriques
      @moyennes_metriques ||=
        agregats_metriques.transform_values { |agregat| agregat[:average] }
    end

    def ecarts_types_metriques
      @ecarts_types_metriques ||=
        agregats_metriques.transform_values { |agregat| agregat[:stddev_pop] }
    end

    private

    def agregats_metriques
      @agregats_metriques ||= begin
        figees, a_calculer = @metriques.partition { |metrique| figee?(metrique) }

        resultats = figees.index_with { |metrique| standard_fige(metrique) }
        resultats.merge!(calcule_metriques(a_calculer))

        @metriques.index_with { |metrique| resultats[metrique] }
      end
    end

    def figee?(metrique)
      @standards_figes&.key?(metrique.to_sym)
    end

    def standard_fige(metrique)
      @standards_figes[metrique.to_sym].slice(:average, :stddev_pop)
    end

    def calcule_metriques(metriques)
      return {} if metriques.empty?

      ligne = @collect_metriques.call
                                 .where.not(metriques: {})
                                 .select(Arel.sql(colonnes_agregation(metriques)))
                                 .take

      resultats_agregation(metriques, ligne)
    end

    def colonnes_agregation(metriques)
      metriques.each_with_index.flat_map do |metrique, index|
        expression = "(metriques ->> #{connexion.quote(metrique.to_s)})::numeric"
        [
          "AVG(#{expression}) AS moyenne_#{index}",
          "STDDEV_POP(#{expression}) AS ecart_type_#{index}"
        ]
      end.join(", ")
    end

    def resultats_agregation(metriques, ligne)
      metriques.each_with_index.each_with_object({}) do |(metrique, index), resultats|
        resultats[metrique] = {
          average: ligne&.public_send("moyenne_#{index}").to_f,
          stddev_pop: ligne&.public_send("ecart_type_#{index}").to_f
        }
      end
    end

    def connexion
      ActiveRecord::Base.connection
    end
  end
end
