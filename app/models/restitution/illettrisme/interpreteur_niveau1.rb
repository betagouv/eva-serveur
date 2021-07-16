# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      def initialize(interpreteur_score)
        @interpreteur_score = interpreteur_score
      end

      def socle_clea?
        interpretations_cefr.all? { |score| score.values[0] == :palier3 }
      end

      def illettrisme_potentiel?
        interpretations_cefr.any? { |score| score.values[0] == :palier0 }
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

      def interpretations_cefr
        @interpretations_cefr ||= score_pour_metriques(Restitution::ScoresNiveau1::METRIQUES_CEFR)
      end

      def interpretations_anlci
        @interpretations_anlci ||= score_pour_metriques(Restitution::ScoresNiveau1::METRIQUES_ANLCI)
      end

      private

      def score_pour_metriques(metriques)
        @interpreteur_score.interpretations(metriques)
      end
    end
  end
end
