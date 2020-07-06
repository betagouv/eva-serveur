# frozen_string_literal: true

module Restitution
  class CalculateurScoresNiveau2
    METRIQUES_ILLETRISME = %i[score_ccf
                              score_numeratie
                              score_syntaxe_orthographe
                              score_memorisation].freeze

    delegate :moyennes_glissantes,
             :ecarts_types_glissants,
             to: :standardisateur_niveau2,
             prefix: :niveau2

    attr_writer :standardisateur_niveau2

    def initialize(parties, standardisateurs_niveau3 = nil)
      @parties = parties
      @standardisateurs_niveau3 = standardisateurs_niveau3
    end

    def scores_niveau2
      @scores_niveau2 ||= scores_niveau3_standardises.transform_values do |valeurs|
        DescriptiveStatistics.mean(valeurs)
      end
    end

    def scores_niveau2_standardises
      @scores_niveau2_standardises =
        scores_niveau2.each_with_object({}) do |(metrique, valeur), memo|
          memo[metrique] = standardisateur_niveau2.standardise(metrique, valeur)
        end
    end

    def calculateurs_niveau2_pour_niveau1
      calculateurs_niveau2.transform_values do |calculateur|
        calculateur.standardisateur_niveau2 = standardisateur_niveau2
        calculateur
      end
    end

    private

    def scores_niveau3_standardises
      METRIQUES_ILLETRISME.each_with_object({}) do |metrique, memo|
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
      standardisateurs_niveau3[partie.situation_id]
        &.standardise(metrique, partie.metriques[metrique.to_s])
    end

    def standardisateurs_niveau3
      @standardisateurs_niveau3 ||=
        @parties.map(&:situation_id).uniq.each_with_object({}) do |situation_id, memo|
          memo[situation_id] ||= Restitution::Standardisateur.new(
            METRIQUES_ILLETRISME,
            proc { Partie.where(situation_id: situation_id) }
          )
        end
    end

    def standardisateur_niveau2
      @standardisateur_niveau2 ||= Restitution::StandardisateurEchantillon.new(
        METRIQUES_ILLETRISME,
        scores_toutes_evaluations
      )
    end

    def scores_toutes_evaluations
      calculateurs_niveau2.values.each_with_object({}) do |calculateur, scores|
        calculateur.scores_niveau2.each do |metrique, score|
          scores[metrique] ||= []
          scores[metrique] << score
        end
      end
    end

    def calculateurs_niveau2
      parties_par_evaluations.transform_values do |parties|
        Restitution::CalculateurScoresNiveau2.new(
          parties,
          standardisateurs_niveau3
        )
      end
    end

    def parties_par_evaluations
      @parties_par_evaluations ||=
        Partie.where.not(metriques: {}).each_with_object({}) do |partie, map|
          map[partie.evaluation_id] ||= []
          map[partie.evaluation_id] << partie
        end
    end
  end
end
