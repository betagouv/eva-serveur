# frozen_string_literal: true

module Restitution
  module Competence
    class ProfilEvacob < Restitution::Competence::Base
      SEUILS = {
        'score_lecture' => {
          ::Competence::PROFIL_4 => 15,
          ::Competence::PROFIL_3 => 11,
          ::Competence::PROFIL_2 => 7,
          ::Competence::PROFIL_1 => 0
        },
        'score_comprehension' => {
          ::Competence::PROFIL_4 => 9,
          ::Competence::PROFIL_3 => 7,
          ::Competence::PROFIL_2 => 5,
          ::Competence::PROFIL_1 => 0
        },
        'score_production' => {
          ::Competence::PROFIL_4 => 18,
          ::Competence::PROFIL_3 => 14,
          ::Competence::PROFIL_2 => 9,
          ::Competence::PROFIL_1 => 0
        },
        'score_parcours_haut' => {
          ::Competence::PROFIL_4H_PLUS_PLUS => 33,
          ::Competence::PROFIL_4H_PLUS => 26,
          ::Competence::PROFIL_4H => 16,
          ::Competence::PROFIL_ABERRANT => 0
        }
      }.freeze

      def initialize(restitution, metrique, *score)
        super(restitution)
        @metrique = metrique
        @score = score.sum if score.present? ## pour éviter de renvoyer 0 si score est nil
      end

      def niveau
        return ::Competence::NIVEAU_INDETERMINE if @restitution.abandon?

        @score ||= @restitution.partie.metriques[@metrique]
        return ::Competence::NIVEAU_INDETERMINE if @score.blank?

        SEUILS[@metrique].each do |niveau, seuil|
          return niveau if @score >= seuil
        end
      end
    end
  end
end
