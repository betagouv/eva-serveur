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
        "A - Très bon"
      when 11..25
        "B - Bon"
      when 26..50
        "C - Moyen"
      when 51..100
        "D - Mauvais"
      end
    end
  end
end
