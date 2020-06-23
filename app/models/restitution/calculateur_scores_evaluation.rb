# frozen_string_literal: true

module Restitution
  class CalculateurScoresEvaluation
    def initialize(parties, standardisateurs, metriques)
      @parties = parties
      @standardisateurs = standardisateurs
      @metriques = metriques
    end

    def scores
      valeurs_des_metriques.transform_values do |valeurs|
        valeurs.sum.fdiv(valeurs.count)
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
      @standardisateurs[partie.situation]&.standardise(metrique, partie.metriques[metrique.to_s])
    end
  end
end
