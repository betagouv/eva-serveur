# frozen_string_literal: true

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
  end
end
