module Restitution
  class Maintenance
    class TempsMotsFrancais
      def calcule(evenements_situation, _)
        Restitution::MetriquesHelper.temps_action(evenements_situation,
                                                  :identification_mot_francais_correct?,
                                                  &:type_mot_francais?)
      end
    end
  end
end
