class AjouteNullFalseABeneficiaireDansEvaluation < ActiveRecord::Migration[7.0]
  def change
    change_column_null :evaluations, :beneficiaire_id, false
    remove_foreign_key 'evaluations', 'beneficiaires'
    add_foreign_key :evaluations, :beneficiaires, on_delete: :cascade
  end
end
