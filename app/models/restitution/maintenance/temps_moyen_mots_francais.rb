# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMoyenMotsFrancais < Restitution::Metriques::Moyenne
      def classe_metrique
        Restitution::Maintenance::TempsMotsFrancais
      end
    end
  end
end
