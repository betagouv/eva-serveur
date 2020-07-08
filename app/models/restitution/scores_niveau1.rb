# frozen_string_literal: true

module Restitution
  class ScoresNiveau1
    METRIQUES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze

    def initialize(scores_niveau2_standardises)
      @scores_niveau2_standardises = scores_niveau2_standardises
    end

    def calcule
      scores_litteratie =
        @scores_niveau2_standardises.calcule.each_with_object([]) do |(metrique, score), memo|
          memo << score if METRIQUES_LITTERATIE.include?(metrique)
        end
      {
        litteratie: DescriptiveStatistics.mean(scores_litteratie.compact),
        numeratie: @scores_niveau2_standardises.calcule[:score_numeratie]
      }
    end

    def scores_par_evaluations
      @scores_niveau2_standardises.scores_standardises_par_evaluations
                                  .transform_values do |scores_niveau2_standardises|
        ScoresNiveau1.new(scores_niveau2_standardises)
      end
    end
  end
end
