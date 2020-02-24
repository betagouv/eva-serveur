# frozen_string_literal: true

module Restitution
  class Securite
    class NombreRetoursDejaQualifies
      def initialize(evenements_situation, _)
        @evenements_situation = evenements_situation
      end

      def calcule
        qualifications_par_dangers = SecuriteHelper.qualifications_par_danger(@evenements_situation)
        qualifications_par_dangers.inject(0) do |memo, (_danger, qualifications)|
          memo + qualifications.count - 1
        end
      end
    end
  end
end
