module Restitution
  class Securite
    class NombreReouvertureZonesSansDanger
      def calcule(evenements_situation, _)
        evenements_situation.select(&:ouverture_zone_sans_danger?)
                            .group_by { |e| e.donnees["zone"] }
                            .inject(0) do |memo, (_danger, ouvertures)|
                              memo + ouvertures.count - 1
                            end
      end
    end
  end
end
