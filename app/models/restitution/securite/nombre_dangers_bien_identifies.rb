# frozen_string_literal: true

module Restitution
  class Securite
    class NombreDangersBienIdentifies < Restitution::Metriques::Base
      def calcule
        @evenements_situation.select(&:est_un_danger_bien_identifie?).count
      end
    end
  end
end
