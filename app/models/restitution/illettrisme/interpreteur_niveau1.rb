module Restitution
  module Illettrisme
    class InterpreteurNiveau1
      CORRESPONDANCES_PALIERS = {
        CEFR: {
          litteratie: {
            palier0: :pre_A1,
            palier1: :A1,
            palier2: :A2,
            palier3: :B1
          },
          numeratie: {
            palier0: :pre_X1,
            palier1: :X1,
            palier2: :X2,
            palier3: :Y1
          }
        },
        ANLCI: {
          litteratie: {
            palier0: :profil1,
            palier1: :profil2,
            palier2: :profil3,
            palier3: :profil4,
            palier4: :profil4_plus,
            palier5: :profil4_plus_plus
          },
          numeratie: {
            palier0: :profil1,
            palier1: :profil2,
            palier2: :profil3,
            palier3: :profil4,
            palier4: :profil4_plus,
            palier5: :profil4_plus_plus
          }
        }
      }.freeze

      def initialize(interpreteur_score)
        @interpreteur_score = interpreteur_score
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
