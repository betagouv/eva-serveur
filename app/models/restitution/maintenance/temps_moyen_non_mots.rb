# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMoyenNonMots < Restitution::Metriques::Moyenne
      def classe_metrique
        Restitution::Maintenance::TempsNonMots
      end
    end
  end
end
