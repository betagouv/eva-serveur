# frozen_string_literal: true

module Restitution
  class CafeDeLaPlace
    class LectureBas < Restitution::Competence::Base
      SEUILS = {
        ::Competence::PROFIL_4 => 15,
        ::Competence::PROFIL_3 => 11,
        ::Competence::PROFIL_2 => 7,
        ::Competence::PROFIL_1 => 0
      }.freeze

      def niveau
        return ::Competence::NIVEAU_INDETERMINE if @restitution.abandon?

        score = @restitution.partie.metriques['score_lecture']
        SEUILS.each do |niveau, seuil|
          return niveau if score >= seuil
        end
      end
    end
  end
end
