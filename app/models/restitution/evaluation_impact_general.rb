module Restitution
  class EvaluationImpactGeneral < Base
    def synthese
      {}
    end

    def lien_poursuivre_evaluation_impact
      "#{ENV['URL_EVA_ENTREPRISES']}/evaluation-impact?evaluation_id=#{evaluation.id}"
    end
  end
end
