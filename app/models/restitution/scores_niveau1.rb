# frozen_string_literal: true

module Restitution
  class ScoresNiveau1
    METACOMPETENCES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze
    METACOMPETENCES_NUMERATIE = %i[score_numeratie].freeze
    METRIQUES_CEFR = %i[litteratie_cefr numeratie_cefr].freeze
    METRIQUES_ANLCI = %i[litteratie_anlci numeratie_anlci].freeze

    def initialize(scores_niveau2_standardises)
      @scores_niveau2_standardises = scores_niveau2_standardises
    end

    def calcule
      {
        litteratie_cefr: litteratie,
        numeratie_cefr: numeratie,
        litteratie_anlci: litteratie,
        numeratie_anlci: numeratie
      }
    end

    def litteratie
      @litteratie ||= calcule_litteratie
    end

    def numeratie
      @numeratie ||= @scores_niveau2_standardises.calcule[:score_numeratie]
    end

    def calcule_litteratie
      scores_litteratie =
        @scores_niveau2_standardises.calcule.each_with_object([]) do |(metrique, score), memo|
          memo << score if METACOMPETENCES_LITTERATIE.include?(metrique)
        end
      DescriptiveStatistics.mean(scores_litteratie.compact)
    end
  end
end
