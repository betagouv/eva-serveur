module Restitution
  class EvaluationImpactGeneral < Base
    def synthese
      {
        performence_collective: calcule_performence_collective,
        agilite_organisationnelle: calcule_agilite_organisationnelle,
        securite_qualite: calcule_securite_qualite,
        mobilite_professionnelle: calcule_mobilite_professionnelle
      }
    end

    def calcule_performence_collective
      Restitution::Entreprises::Impact::InterpretationScoring.new.calcule_performence_collective(@evenements)
    end

    def calcule_agilite_organisationnelle
      Restitution::Entreprises::Impact::InterpretationScoring.new.calcule_agilite_organisationnelle(@evenements)
    end

    def calcule_securite_qualite
      Restitution::Entreprises::Impact::InterpretationScoring.new.calcule_securite_qualite(@evenements)
    end

    def calcule_mobilite_professionnelle
      Restitution::Entreprises::Impact::InterpretationScoring.new.calcule_mobilite_professionnelle(@evenements)
    end
  end
end
