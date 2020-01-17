# frozen_string_literal: true

module Restitution
  class Securite
    class TempsBonnesQualificationsDangers
      def calcule(evenements_situation)
        evenements = evenements_situation.select do |e|
          e.ouverture_zone_danger? || e.bonne_qualification_danger?
        end
        evenements_par_danger = evenements.group_by { |e| e.donnees['danger'] }

        temps_par_dangers = {}
        evenements_par_danger.each do |danger, les_evenements|
          temps = MetriquesHelper.temps_entre_couples les_evenements
          temps_par_dangers[danger] = temps.last if temps.last.present?
        end
        temps_par_dangers
      end
    end
  end
end
