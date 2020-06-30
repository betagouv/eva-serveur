# frozen_string_literal: true

module Restitution
  class CalculateurScoresEvaluation
    METRIQUES_LITTERATIE = %i[score_ccf score_syntaxe_orthographe score_memorisation].freeze

    def initialize(parties, metriques, standardisateurs)
      @parties = parties
      @metriques = metriques
      @standardisateurs = standardisateurs
    end

    def scores_niveau2
      @scores_niveau2 ||= valeurs_des_metriques.transform_values do |valeurs|
        DescriptiveStatistics.mean(valeurs)
      end
    end

    def scores_niveau2_standardises(standardisateur_niveau2)
      @scores_niveau2_standardises =
        scores_niveau2.each_with_object({}) do |(metrique, valeur), memo|
          memo[metrique] = standardisateur_niveau2.standardise(metrique, valeur)
        end
    end

    def scores_niveau1(standardisateur_niveau2)
      scores_niveau2_standardises = scores_niveau2_standardises(standardisateur_niveau2)
      scores_litteratie = scores_niveau2_standardises.each_with_object([]) do |score, memo|
        memo << score[1] if METRIQUES_LITTERATIE.include?(score[0])
      end
      {
        litteratie: DescriptiveStatistics.mean(scores_litteratie.compact),
        numeratie: scores_niveau2_standardises[:score_numeratie]
      }
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
