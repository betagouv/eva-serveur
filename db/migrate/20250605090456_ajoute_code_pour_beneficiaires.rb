class AjouteCodePourBeneficiaires < ActiveRecord::Migration[7.2]
  def change
    add_column :beneficiaires, :code, :string
    add_index :beneficiaires, :code, unique: true
  end
end
