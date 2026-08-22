module Restitution
  class GlobaleEvapro < Globale
    def persiste
      restitution_complete = Restitution::Evapro::Completude.new(evaluation, restitutions).calcule
      @evaluation.update(completude: restitution_complete)
    end

    def diag_risques_entreprise
      @diag_risques_entreprise ||= selectionne_derniere_restitution(Situation::DIAG_RISQUES_ENTREPRISE)
    end

    def evaluation_impact_general
      @evaluation_impact_general ||= selectionne_derniere_restitution(Situation::EVALUATION_IMPACT_GENERAL)
    end
  end
end
