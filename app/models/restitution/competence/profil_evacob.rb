# frozen_string_literal: true

module Restitution
  module Competence
    class ProfilEvacob < Restitution::Competence::Base
      SEUILS = {
        "score_lecture" => {
          ::Competence::PROFIL_4 => 15,
          ::Competence::PROFIL_3 => 11,
          ::Competence::PROFIL_2 => 7,
          ::Competence::PROFIL_1 => 0
        },
        "score_comprehension" => {
          ::Competence::PROFIL_4 => 9,
          ::Competence::PROFIL_3 => 7,
          ::Competence::PROFIL_2 => 5,
          ::Competence::PROFIL_1 => 0
        },
        "score_production" => {
          ::Competence::PROFIL_4 => 18,
          ::Competence::PROFIL_3 => 14,
          ::Competence::PROFIL_2 => 9,
          ::Competence::PROFIL_1 => 0
        },
        "score_parcours_haut" => {
          ::Competence::PROFIL_4H_PLUS_PLUS => 33,
          ::Competence::PROFIL_4H_PLUS => 26,
          ::Competence::PROFIL_4H => 16,
          ::Competence::PROFIL_ABERRANT => 0
        },
        "profil_numeratie" => {
          ::Competence::PROFIL_4_PLUS => 5,
          ::Competence::PROFIL_4 => 4,
          ::Competence::PROFIL_3 => 3,
          ::Competence::PROFIL_2 => 2,
          ::Competence::PROFIL_1 => 1
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

      def profil_numeratie
        return ::Competence::NIVEAU_INDETERMINE unless a_passe_le_niveau_1?

        @score ||= @restitution.partie.metriques[@metrique]
        return ::Competence::NIVEAU_INDETERMINE if @score.blank?

        SEUILS[@metrique].each do |profil, niveau|
          return profil if @score == niveau
        end
      end

      DERNIERE_QUESTION_NIVEAU_1 = "N1Pvn4"
      def a_passe_le_niveau_1?
        @restitution.partie.evenements.find do |evenement|
          evenement.question_nom_technique == DERNIERE_QUESTION_NIVEAU_1
        end.present?
      end
    end
  end
end
