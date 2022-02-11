# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      CORRESPONDANCES_PALIERS = {
        CEFR: {
          litteratie: {
            palier0: 'pre-A1',
            palier1: 'A1',
            palier2: 'A2',
            palier3: 'B1'
          },
          numeratie: {
            palier0: 'pre-X1',
            palier1: 'X1',
            palier2: 'X2',
            palier3: 'Y1'
          }
        },
        ANLCI: {
          litteratie: {
            palier0: '1',
            palier1: '2',
            palier2: '3',
            palier3: '4',
            palier4: '4 plus',
            palier5: '4 plus plus'
          },
          numeratie: {
            palier0: '1',
            palier1: '2',
            palier2: '3',
            palier3: '4',
            palier4: '4 plus',
            palier5: '4 plus plus'
          }
        }
      }.freeze

      def initialize(interpreteur_score)
        @interpreteur_score = interpreteur_score
      end

      def socle_clea?
        interpretations_cefr[:litteratie] == 'B1' and interpretations_cefr[:numeratie] == 'Y1'
      end

      def illettrisme_potentiel?
        interpretations_cefr[:litteratie] == 'pre-A1' or
          interpretations_cefr[:numeratie] == 'pre-X1'
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
        @interpretations_cefr ||= interprete_score_pour(:CEFR)
      end

      def interpretations_anlci
        @interpretations_anlci ||= interprete_score_pour(:ANLCI)
      end

      private

      def interprete_score_pour(referentiel)
        interpretations = @interpreteur_score.interpretations(
          Restitution::ScoresNiveau1::METRIQUES_NIVEAU1,
          referentiel
        )
        interpretations.each_with_object({}) do |interpretation, traductions|
          metrique = interpretation.keys.first
          palier = interpretation.values.first
          traductions[metrique] = CORRESPONDANCES_PALIERS[referentiel][metrique][palier]
        end
      end
    end
  end
end
