# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMoyenMotsFrancais < Restitution::Metriques::Base
      def calcule
        Restitution::MetriquesHelper.temps_action_moyen(@evenements_situation,
                                                        :identification_mot_francais_correct?,
                                                        &:type_mot_francais?)
      end
    end
  end
end
