class AjouteComptePourBeneficiaire < ActiveRecord::Migration[7.2]
  def change
    add_reference :beneficiaires, :compte, foreign_key: true, type: :uuid
  end
end
