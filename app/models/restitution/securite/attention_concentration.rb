module Restitution
  class Securite
    class AttentionConcentration < Restitution::Competence::Base
      def niveau
        return ::Competence::NIVEAU_INDETERMINE if @restitution.abandon?

        temps_recherche_standardise =
          @restitution.cote_z_metriques["temps_moyen_recherche_zones_dangers"]
        return ::Competence::NIVEAU_INDETERMINE if temps_recherche_standardise.blank?

        evalue(-1 * temps_recherche_standardise)
      end

      private

      def evalue(score)
        if score.positive?
          ::Competence::NIVEAU_4
        elsif score > -0.5
          ::Competence::NIVEAU_3
        elsif score > -1
          ::Competence::NIVEAU_2
        else
          ::Competence::NIVEAU_1
        end
      end
    end
  end
end
