module Restitution
  class DiagRisquesEntreprise < Base
    def synthese
      {
        pourcentage_risque: calcule_pourcentage_risque
      }
    end

    def calcule_pourcentage_risque
      Restitution::Entreprises::PourcentageRisque.new.calcule(@evenements)
    end

    def palier
      case synthese[:pourcentage_risque]
      when 0..10
        "A"
      when 11..25
        "B"
      when 26..50
        "C"
      when 51..100
        "D"
      end
    end
  end
end
