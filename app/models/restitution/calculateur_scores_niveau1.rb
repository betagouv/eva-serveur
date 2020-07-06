# frozen_string_literal: true

module Restitution
  class CalculateurScoresNiveau1
    METRIQUES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze

    delegate :moyennes_glissantes,
             :ecarts_types_glissants,
             to: :standardisateur_niveau1,
             prefix: :niveau1

    def initialize(calculateur_niveau2)
      @calculateur_niveau2 = calculateur_niveau2
    end

    def scores_niveau1
      scores_litteratie =
        @calculateur_niveau2
        .scores_niveau2_standardises.each_with_object([]) do |(metrique, score), memo|
          memo << score if METRIQUES_LITTERATIE.include?(metrique)
        end
      {
        litteratie: DescriptiveStatistics.mean(scores_litteratie.compact),
        numeratie: @calculateur_niveau2.scores_niveau2_standardises[:score_numeratie]
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
      calculateurs_evaluations.values.each_with_object({}) do |calculateur_evaluation, scores|
        calculateur_evaluation.scores_niveau1.each do |metrique, score|
          scores[metrique] ||= []
          scores[metrique] << score
        end
      end
    end

    def calculateurs_evaluations
      @calculateur_niveau2.calculateurs_niveau2_pour_niveau1
                          .transform_values do |calculateur_niveau2|
        CalculateurScoresNiveau1.new(calculateur_niveau2)
      end
    end
  end
end
