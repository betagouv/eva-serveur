# frozen_string_literal: true

module Restitution
  class CalculateurScoresEvaluation
    def initialize(parties, metriques, standardisateurs)
      @parties = parties
      @metriques = metriques
      @standardisateurs = standardisateurs
    end

    def scores
      @scores ||= valeurs_des_metriques.transform_values do |valeurs|
        valeurs.sum.fdiv(valeurs.count)
      end
    end

    def cote_z_scores(standardisateur_evaluations)
      @cote_z_scores ||= scores.each_with_object({}) do |(metrique, valeur), memo|
        memo[metrique] = standardisateur_evaluations.standardise(metrique, valeur)
      end
    end

    private

    def valeurs_des_metriques
      @metriques.each_with_object({}) do |metrique, memo|
        @parties.each do |partie|
          cote_z = standardise(partie, metrique)
          next if cote_z.nil?

          memo[metrique] ||= []
          memo[metrique] << cote_z
        end
        memo
      end
    end

    def standardise(partie, metrique)
      @standardisateurs[partie.situation_id]&.standardise(metrique, partie.metriques[metrique.to_s])
    end
  end
end
