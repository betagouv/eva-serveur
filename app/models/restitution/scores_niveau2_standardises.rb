# frozen_string_literal: true

module Restitution
  class ScoresNiveau2Standardises
    delegate :moyennes_glissantes,
             :ecarts_types_glissants,
             to: :standardisateur_niveau2,
             prefix: :niveau2

    def initialize(scores_niveau2, standardisateur_niveau2 = nil)
      @scores_niveau2 = scores_niveau2
      @standardisateur_niveau2 = standardisateur_niveau2
    end

    def calcule
      @calcule =
        @scores_niveau2.calcule.each_with_object({}) do |(metrique, valeur), memo|
          memo[metrique] = standardisateur_niveau2.standardise(metrique, valeur)
        end
    end

    def scores_niveau2_standardises_par_evaluations
      @scores_niveau2.scores_niveau2_par_evaluations.transform_values do |scores_niveau2|
        ScoresNiveau2Standardises.new(scores_niveau2, standardisateur_niveau2)
      end
    end

    private

    def standardisateur_niveau2
      @standardisateur_niveau2 ||= Restitution::StandardisateurEchantillon.new(
        Restitution::ScoresNiveau2::METRIQUES_ILLETRISME,
        scores_toutes_evaluations
      )
    end

    def scores_toutes_evaluations
      @scores_niveau2.scores_niveau2_par_evaluations.values
                     .each_with_object({}) do |scores_niveau2, scores|
        scores_niveau2.calcule.each do |nom, score|
          scores[nom] ||= []
          scores[nom] << score
        end
      end
    end
  end
end
