# frozen_string_literal: true

module Restitution
  class Securite
    class DelaiMoyenOuverturesZonesDangers < Restitution::Metriques::Moyenne
      def classe_metrique
        Securite::METRIQUES['delai_ouvertures_zones_dangers']
      end
    end
  end
end
