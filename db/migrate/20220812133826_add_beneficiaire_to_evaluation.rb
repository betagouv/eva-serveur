class AddBeneficiaireToEvaluation < ActiveRecord::Migration[7.0]
  def change
    add_reference :evaluations, :beneficiaire, null: true, foreign_key: true, type: :uuid
  end
end
