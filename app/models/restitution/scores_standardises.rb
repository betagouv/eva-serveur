# frozen_string_literal: true

module Restitution
  class ScoresStandardises
    delegate :moyennes_metriques,
             :ecarts_types_metriques,
             to: :standardisateur

    def initialize(scores, standardisateur = nil)
      @scores = scores
      @standardisateur = standardisateur
    end

    def calcule
      @calcule =
        @scores.calcule.each_with_object({}) do |(metrique, valeur), memo|
          memo[metrique] = standardisateur.standardise(metrique, valeur)
        end
    end

    def scores_standardises_par_evaluations
      @scores.scores_par_evaluations.transform_values do |scores|
        ScoresStandardises.new(scores, standardisateur)
      end
    end

    private

    def standardisateur
      @standardisateur ||= StandardisateurFige.instancie_pour :plus_haut_niveau
    end
  end
end
