# frozen_string_literal: true

module Restitution
  class StandardisateurFige < Standardisateur
    STANDARDS = {
      livraison: {
        score_syntaxe_orthographe: { average: 10.81, stddev_pop: 7.78 },
        score_numeratie: { average: 5.5, stddev_pop: 3.8 },
        score_ccf: { average: 18.4, stddev_pop: 7.41 }
      },
      objets_trouves: {
        score_numeratie: { average: 6.38, stddev_pop: 5.22 },
        score_ccf: { average: 10.0, stddev_pop: 4.14 },
        score_memorisation: { average: 1.21, stddev_pop: 3.35 }
      },
      maintenance: {
        score_ccf: { average: 425.04, stddev_pop: 245.78 }
      },
      securite: {
        temps_moyen_recherche_zones_dangers: { average: 17.83, stddev_pop: 9.46 }
      },
      plus_haut_niveau: {
        score_ccf: { average: 0.16, stddev_pop: 0.61 },
        score_syntaxe_orthographe: { average: 0.09, stddev_pop: 0.83 },
        score_memorisation: { average: 0.23, stddev_pop: 0.93 },
        score_numeratie: { average: 0, stddev_pop: 1 },
        litteratie: { average: 0.16, stddev_pop: 0.65 },
        numeratie: { average: 0, stddev_pop: 1 }
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
