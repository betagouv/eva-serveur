module Beneficiaires
  class StatutSuivi
    def self.par_beneficiaire(ids)
      Beneficiaire.where(id: ids).pluck(:id, expression_statut).to_h
    end

    def self.expression_statut
      derniere_evaluation_concernee = EvaluationEva
        .where("evaluations.beneficiaire_id = beneficiaires.id")
        .where(EvaluationsEva::StatutSuivi.condition_concernee)
        .order(debutee_le: :desc)
        .limit(1)
        .select(EvaluationsEva::StatutSuivi.expression_statut)

      Arel.sql("COALESCE((#{derniere_evaluation_concernee.to_sql}), 'non_concerne')")
    end
  end
end
