# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      def initialize(scores, restitutions)
        @interpreteur_score = InterpreteurScores.new(scores)
        @detecteur_illettrisme = DetecteurIllettrisme.new(restitutions)
      end

      def socle_clea?
        interpretations == [{ litteratie: :palier3 }, { numeratie: :palier3 }]
      end

      def synthese
        if @detecteur_illettrisme.illettrisme_potentiel?
          'illettrisme_potentiel'
        elsif socle_clea?
          'socle_clea'
        else
          'ni_ni'
        end
      end

      def interpretations
        @interpretations ||= @interpreteur_score
                             .interpretations(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1)
      end
    end
  end
end
