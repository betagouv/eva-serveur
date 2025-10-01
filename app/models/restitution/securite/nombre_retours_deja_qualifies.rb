module Restitution
  class Securite
    class NombreRetoursDejaQualifies
      def calcule(evenements_situation, _)
        qualifications_par_dangers = SecuriteHelper.qualifications_par_danger(evenements_situation)
        qualifications_par_dangers.inject(0) do |memo, (_danger, qualifications)|
          memo + qualifications.count - 1
        end
      end
    end
  end
end
