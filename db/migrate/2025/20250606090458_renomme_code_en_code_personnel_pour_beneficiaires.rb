class RenommeCodeEnCodePersonnelPourBeneficiaires < ActiveRecord::Migration[7.2]
  class Beneficiaire < ApplicationRecord; end

  def change
    rename_column :beneficiaires, :code, :code_personnel
  end
end
