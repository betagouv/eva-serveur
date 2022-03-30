# frozen_string_literal: true

module Restitution
  class ScoresNiveau1
    POIDS_METACOMPETENCES_LITTERATIE = {
      score_ccf: 1,
      score_syntaxe_orthographe: 1,
      score_memorisation: 0.25
    }.freeze
    METACOMPETENCES_LITTERATIE = POIDS_METACOMPETENCES_LITTERATIE.keys
    METACOMPETENCES_NUMERATIE = %i[score_numeratie].freeze
    METRIQUES_NIVEAU1 = %i[litteratie numeratie].freeze

    def initialize(scores_niveau2_standardises)
      @scores_niveau2_standardises = scores_niveau2_standardises
    end

    def calcule
      {
        litteratie: litteratie,
        numeratie: numeratie
      }
    end

    def litteratie
      @litteratie ||= calcule_litteratie
    end

    def numeratie
      @numeratie ||= @scores_niveau2_standardises.calcule[:score_numeratie]
    end

    def calcule_litteratie
      poids_total = 0
      sommes_scores = 0
      @scores_niveau2_standardises.calcule.each do |(metrique, score)|
        next unless POIDS_METACOMPETENCES_LITTERATIE.keys.include?(metrique) &&
                    score.present?

        poids = POIDS_METACOMPETENCES_LITTERATIE[metrique]
        sommes_scores += score * poids
        poids_total += poids
      end
      sommes_scores.fdiv(poids_total)
    end
  end
end
