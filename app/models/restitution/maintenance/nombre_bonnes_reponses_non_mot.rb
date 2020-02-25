# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreBonnesReponsesNonMot < Restitution::Metriques::Base
      def calcule(evenements_situation, _)
        evenements_situation.select(&:identification_non_mot_correct?).count
      end
    end
  end
end
