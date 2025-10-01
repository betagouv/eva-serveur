module Restitution
  class Maintenance
    class TempsNonMots
      def calcule(evenements_situation, _)
        Restitution::MetriquesHelper.temps_action(evenements_situation,
                                                  :identification_non_mot_correct?,
                                                  &:type_non_mot?)
      end
    end
  end
end
