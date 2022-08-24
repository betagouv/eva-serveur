class AddAnonymiseLeToBeneficiaires < ActiveRecord::Migration[7.0]
  def change
    add_column :beneficiaires, :anonymise_le, :datetime
  end
end
