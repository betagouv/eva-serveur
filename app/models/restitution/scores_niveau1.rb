# frozen_string_literal: true

module Restitution
  class ScoresNiveau1
    METACOMPETENCES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze
    METACOMPETENCES_NUMERATIE = %i[score_numeratie].freeze
    METRIQUES_NIVEAU1 = %i[litteratie numeratie].freeze

    def initialize(scores_niveau2_standardises)
      @scores_niveau2_standardises = scores_niveau2_standardises
    end

    def calcule
      scores_litteratie =
        @scores_niveau2_standardises.calcule.each_with_object([]) do |(metrique, score), memo|
          memo << score if METACOMPETENCES_LITTERATIE.include?(metrique)
        end
      {
        litteratie: DescriptiveStatistics.mean(scores_litteratie.compact),
        numeratie: @scores_niveau2_standardises.calcule[:score_numeratie]
      }
    end
  end
end
