module Restitution
  class StandardisateurFige < Standardisateur
    STANDARDS = {
      livraison: {
        score_syntaxe_orthographe: { average: 0.49, stddev_pop: 0.24 },
        score_numeratie: { average: 0.09, stddev_pop: 0.04 },
        score_ccf: { average: 0.71, stddev_pop: 0.23 }
      },
      objets_trouves: {
        score_numeratie: { average: 0.09, stddev_pop: 0.04 },
        score_ccf: { average: 0.28, stddev_pop: 0.09 },
        score_memorisation: { average: 0.22, stddev_pop: 0.11 }
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
