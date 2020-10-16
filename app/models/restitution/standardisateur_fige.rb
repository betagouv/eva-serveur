# frozen_string_literal: true

module Restitution
  class StandardisateurFige < Standardisateur
    STANDARDS = {
      livraison: {
        score_syntaxe_orthographe: { moyenne: 0.49, ecart_type: 0.24 },
        score_numeratie: { moyenne: 0.09, ecart_type: 0.04 },
        score_ccf: { moyenne: 0.71, ecart_type: 0.23 }
      },
      objets_trouves: {
        score_numeratie: { moyenne: 0.09, ecart_type: 0.04 },
        score_ccf: { moyenne: 0.28, ecart_type: 0.09 },
        score_memorisation: { moyenne: 0.22, ecart_type: 0.11 }
      },
      maintenance: {
        score_ccf: { moyenne: 425.04, ecart_type: 245.78 }
      }
    }.freeze

    def self.instancie_pour(situation)
      new STANDARDS[situation]
    end

    attr_reader :moyenne_metriques, :ecart_type_metriques

    def initialize(standards)
      @moyenne_metriques = standards&.transform_values { |references| references[:moyenne] }
      @ecart_type_metriques = standards&.transform_values { |references| references[:ecart_type] }
    end
  end
end
