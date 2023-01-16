class AjouteResponsableSuiviAEvaluation < ActiveRecord::Migration[7.0]
  def change
    add_reference :evaluations, :responsable_suivi, type: :uuid

    add_foreign_key :evaluations, :comptes, column: :responsable_suivi_id
  end
end
