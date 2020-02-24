# frozen_string_literal: true

module Restitution
  class Securite
    class DelaiMoyenOuverturesZonesDangers < Restitution::Metriques::Base
      def calcule
        delais = Securite::METRIQUES['delai_ouvertures_zones_dangers']
                 .new(@evenements_situation, @evenements_entrainement)
                 .calcule

        return nil if delais.empty?

        delais.sum.fdiv(delais.size)
      end
    end
  end
end
