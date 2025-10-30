module Restitution
  class EvaluationImpactGeneral < Base
    def synthese
      {
        performance_collective: calcule_performance_collective,
        agilite_organisationnelle: calcule_agilite_organisationnelle,
        securite_qualite: calcule_securite_qualite,
        mobilite_professionnelle: calcule_mobilite_professionnelle,
        score_cout: calcule_score_cout,
        score_strategie: calcule_score_strategie,
        score_numerique: calcule_score_numerique
      }
    end

    def calcule_performance_collective
      Restitution::Entreprises::Impact::InterpretationScoring.new.calcule_performance_collective(@evenements)
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

    def calcule_score_cout
      Restitution::Entreprises::Impact::ScoreParImpact.new.calcule_score_cout(@evenements)
    end

    def calcule_score_strategie
      Restitution::Entreprises::Impact::ScoreParImpact.new.calcule_score_strategie(@evenements)
    end

    def calcule_score_numerique
      Restitution::Entreprises::Impact::ScoreParImpact.new.calcule_score_numerique(@evenements)
    end
  end
end
