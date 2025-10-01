module Restitution
  class ScoresNiveau2
    METRIQUES_ILLETTRISME = %i[score_ccf
                               score_numeratie
                               score_syntaxe_orthographe
                               score_memorisation].freeze

    def initialize(parties, standardisateurs_niveau3 = nil)
      @parties = parties
      @standardisateurs_niveau3 = standardisateurs_niveau3
    end

    def calcule
      @calcule ||= scores_niveau3_standardises.transform_values do |valeurs|
        DescriptiveStatistics.mean(valeurs)
      end
    end

    private

    def scores_niveau3_standardises
      METRIQUES_ILLETTRISME.each_with_object({}) do |metrique, memo|
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
          nom_situation = Situation.find(situation_id).nom_technique
          memo[situation_id] ||= StandardisateurFige.instancie_pour nom_situation.to_sym
        end
    end
  end
end
