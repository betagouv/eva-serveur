module EvaluationsEva
  class TableauDeBordMisesEnAction
    def self.relation(ability)
      EvaluationEva.accessible_by(ability).illettrisme_potentiel
                .mise_en_action_a_renseigner
                .competences_de_base_completes
                .non_anonymes
                .order(created_at: :desc)
                .includes(:mise_en_action)
    end
  end
end
