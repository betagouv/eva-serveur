# frozen_string_literal: true

module Evaluations
  class PassationBeneficiaire
    class TableauDeBordMisesEnAction
      def self.relation(ability)
        Evaluation.accessible_by(ability).illettrisme_potentiel
                  .sans_mise_en_action
                  .competences_de_base_completes
                  .non_anonymes
                  .order(created_at: :desc)
                  .includes(:mise_en_action)
      end
    end
  end
end
