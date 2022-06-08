# frozen_string_literal: true

module Restitution
  module Competence
    class ProfileEvacob < Restitution::Competence::Base
      SEUILS = {
        'score_lecture' => {
          ::Competence::PROFIL_4 => 15,
          ::Competence::PROFIL_3 => 11,
          ::Competence::PROFIL_2 => 7,
          ::Competence::PROFIL_1 => 0
        },
        'score_comprehention' => {
          ::Competence::PROFIL_4 => 9,
          ::Competence::PROFIL_3 => 7,
          ::Competence::PROFIL_2 => 5,
          ::Competence::PROFIL_1 => 0
        }
      }.freeze

      def initialize(restitution, metrique)
        super(restitution)
        @metrique = metrique
      end

      def niveau
        return ::Competence::NIVEAU_INDETERMINE if @restitution.abandon?

        score = @restitution.partie.metriques[@metrique]
        return ::Competence::NIVEAU_INDETERMINE if score.blank?

        SEUILS[@metrique].each do |niveau, seuil|
          return niveau if score >= seuil
        end
      end
    end
  end
end
