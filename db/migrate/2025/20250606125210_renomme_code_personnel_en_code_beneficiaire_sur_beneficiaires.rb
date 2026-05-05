class RenommeCodePersonnelEnCodeBeneficiaireSurBeneficiaires < ActiveRecord::Migration[7.2]
  class Beneficiaire < ApplicationRecord; end

  def change
    rename_column :beneficiaires, :code_personnel, :code_beneficiaire
  end
end
