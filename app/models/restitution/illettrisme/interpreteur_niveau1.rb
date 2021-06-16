# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      def initialize(interpreteur_score)
        @interpreteur_score = interpreteur_score
      end

      def socle_clea?
        interpretations.all? { |score| score.values[0] == :palier3 }
      end

      def illettrisme_potentiel?
        interpretations.any? { |score| score.values[0] == :palier0 }
      end

      def synthese
        if illettrisme_potentiel?
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
