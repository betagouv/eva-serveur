module Restitution
  class ScoresNiveau1
    METACOMPETENCES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze
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
      scores_litteratie =
        @scores_niveau2_standardises.calcule.each_with_object([]) do |(metrique, score), memo|
          memo << score if METACOMPETENCES_LITTERATIE.include?(metrique)
        end
      DescriptiveStatistics.mean(scores_litteratie.compact)
    end
  end
end
