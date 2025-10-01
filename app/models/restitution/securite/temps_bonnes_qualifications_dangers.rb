module Restitution
  class Securite
    class TempsBonnesQualificationsDangers
      def calcule(evenements_situation, _)
        temps_par_danger = {}
        evenements_par_danger = SecuriteHelper.filtre_par_danger(evenements_situation) do |e|
          e.ouverture_zone_danger? || e.bonne_qualification_danger?
        end
        evenements_par_danger.each do |danger, les_evenements|
          temps = MetriquesHelper.temps_entre_couples les_evenements
          temps_par_danger[danger] = temps.first if temps.first.present?
        end
        temps_par_danger
      end
    end
  end
end
