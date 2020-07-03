# frozen_string_literal: true

module Restitution
  class CalculateurScoresNiveau1
    METRIQUES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze

    def initialize(calculateur_niveau2)
      @calculateur_niveau2 = calculateur_niveau2
    end

    def scores_niveau1
      scores_litteratie =
        @calculateur_niveau2.scores_niveau2_standardises.each_with_object([]) do |score, memo|
          memo << score[1] if METRIQUES_LITTERATIE.include?(score[0])
        end
      {
        litteratie: DescriptiveStatistics.mean(scores_litteratie.compact),
        numeratie: @calculateur_niveau2.scores_niveau2_standardises[:score_numeratie]
      }
    end
  end
end
