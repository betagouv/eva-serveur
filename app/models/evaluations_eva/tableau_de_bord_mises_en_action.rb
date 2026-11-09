module EvaluationsEva
  class TableauDeBordMisesEnAction
    def self.relation(ability)
      ordre = Arel.sql("mises_en_action.repondue_le NULLS FIRST, evaluations.created_at ASC")
      EvaluationEva.accessible_by(ability).illettrisme_potentiel
                .mise_en_action_a_renseigner
                .competences_de_base_completes
                .non_anonymes
                .order(ordre)
    end
  end
end
