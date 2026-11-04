module Beneficiaires
  class StatutSuivi
    def self.par_beneficiaire(ids)
      Beneficiaire.where(id: ids).pluck(:id, sql_statut_suivi).to_h
    end

    # Le statut de suivi de la dernière évaluation suivie du bénéficiaire
    def self.sql_statut_suivi
      derniere_evaluation_suivie = EvaluationEva
        .where("evaluations.beneficiaire_id = beneficiaires.id")
        .where(EvaluationsEva::StatutSuivi.sql_evaluation_suivie)
        .order(debutee_le: :desc)
        .limit(1)
        .select(EvaluationsEva::StatutSuivi.sql_statut_suivi)

      Arel.sql("COALESCE((#{derniere_evaluation_suivie.to_sql}), 'non_concerne')")
    end

    def self.filtre_par_statuts(relation, statuts)
      relation.where("#{sql_statut_suivi} IN (?)",
                     statuts & EvaluationsEva::StatutSuivi::STATUTS_FILTRE)
    end

    def self.sql_ordre_de_tri
      EvaluationsEva::StatutSuivi.sql_ordre_de_tri_pour(sql_statut_suivi)
    end
  end
end
