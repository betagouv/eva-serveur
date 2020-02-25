# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreBonnesReponsesMotFrancais < Restitution::Metriques::Base
      def calcule(evenements_situation, _)
        evenements_situation.select(&:identification_mot_francais_correct?).count
      end
    end
  end
end
