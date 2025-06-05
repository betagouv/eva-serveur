class AjouteCodePourBeneficiairesExistant < ActiveRecord::Migration[7.2]
  def up
    Beneficiaire.where(code: nil).find_each do |beneficiaire|
      beneficiaire.genere_code_unique
      beneficiaire.save(validate: false)
    end
  end

  def down
    Beneficiaire.update_all(code: nil)
  end
end
