# frozen_string_literal: true

module Restitution
  class Securite
    class NombreDangersBienQualifies
      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        qualifications_par_danger.map do |_danger, qualifications|
          qualifications.max_by(&:created_at)
        end.count(&:bonne_reponse?)
      end

      private

      def qualifications_par_danger
        SecuriteHelper.filtre_par_danger(@evenements_situation, &:qualification_danger?)
      end
    end
  end
end
