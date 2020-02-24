# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsNonMots < Restitution::Metriques::Base
      def calcule
        Restitution::MetriquesHelper.temps_action(@evenements_situation,
                                                  :identification_non_mot_correct?,
                                                  &:type_non_mot?)
      end
    end
  end
end
