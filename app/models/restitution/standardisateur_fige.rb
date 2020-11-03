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
      },
      plus_haut_niveau: {
        score_ccf: { moyenne: 0.16, ecart_type: 0.61 },
        score_numeratie: { moyenne: 0.11, ecart_type: 0.48 },
        score_syntaxe_orthographe: { moyenne: 0.09, ecart_type: 0.83 },
        score_memorisation: { moyenne: 0.23, ecart_type: 0.93 },
        numeratie: { moyenne: 0, ecart_type: 0.83 },
        litteratie: { moyenne: 0.16, ecart_type: 0.65 }
      }
    }.freeze

    def self.instancie_pour(situation)
      new STANDARDS[situation]
    end

    attr_reader :moyennes_metriques, :ecarts_types_metriques

    def initialize(standards)
      @moyennes_metriques = standards&.transform_values { |references| references[:moyenne] }
      @ecarts_types_metriques = standards&.transform_values { |references| references[:ecart_type] }
    end
  end
end
