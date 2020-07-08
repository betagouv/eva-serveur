# frozen_string_literal: true

module Restitution
  class ScoresNiveau1
    METRIQUES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze

    delegate :moyennes_glissantes,
             :ecarts_types_glissants,
             to: :standardisateur_niveau1,
             prefix: :niveau1

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

    private

    def standardisateur_niveau1
      @standardisateur_niveau1 ||= Restitution::StandardisateurEchantillon.new(
        %i[litteratie numeratie].freeze,
        scores_toutes_evaluations
      )
    end

    def scores_toutes_evaluations
      scores_niveau1_par_evaluations.values.each_with_object({}) do |scores_niveau1, scores|
        scores_niveau1.calcule.each do |metrique, score|
          scores[metrique] ||= []
          scores[metrique] << score
        end
      end
    end

    def scores_niveau1_par_evaluations
      @scores_niveau2_standardises.scores_niveau2_standardises_par_evaluations
                                  .transform_values do |scores_niveau2_standardises|
        ScoresNiveau1.new(scores_niveau2_standardises)
      end
    end
  end
end
