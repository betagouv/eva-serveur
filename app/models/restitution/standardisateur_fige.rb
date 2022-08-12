# frozen_string_literal: true

module Restitution
  class StandardisateurFige < Standardisateur
    STANDARDS = {
      livraison: {
        score_syntaxe_orthographe: { average: 10.77, stddev_pop: 7.78 },
        score_numeratie: { average: 5.49, stddev_pop: 3.79 },
        score_ccf: { average: 18.33, stddev_pop: 7.42 }
      },
      objets_trouves: {
        score_numeratie: { average: 6.35, stddev_pop: 5.22 },
        score_ccf: { average: 9.97, stddev_pop: 4.14 },
        score_memorisation: { average: 1.19, stddev_pop: 3.34 }
      },
      maintenance: {
        score_ccf: { average: 425.04, stddev_pop: 245.78 }
      },
      securite: {
        temps_moyen_recherche_zones_dangers: { average: 17.83, stddev_pop: 9.46 }
      },
      plus_haut_niveau: {
        score_ccf: { average: 0.03, stddev_pop: 2.11 },
        score_syntaxe_orthographe: { average: 0.0, stddev_pop: 1.0 },
        score_memorisation: { average: 0.0, stddev_pop: 1.0 },
        score_numeratie: { average: -0.02, stddev_pop: 0.91 },
        litteratie: { average: 0.01, stddev_pop: 1.03 },
        numeratie: { average: 0.0, stddev_pop: 0.96 }
      }
    }.freeze

    def self.instancie_pour(situation)
      new STANDARDS[situation]
    end

    attr_reader :moyennes_metriques, :ecarts_types_metriques

    def initialize(standards)
      super()
      @moyennes_metriques = standards&.transform_values { |references| references[:average] }
      @ecarts_types_metriques = standards&.transform_values { |references| references[:stddev_pop] }
    end
  end
end
