class AjouteCodePourBeneficiairesExistant < ActiveRecord::Migration[7.2]
  def up
    Beneficiaire.where(code_personnel: nil).find_each do |beneficiaire|
      beneficiaire.genere_code_personnel_unique
      beneficiaire.save(validate: false)
    end
  end

  def down
    Beneficiaire.update_all(code_personnel: nil)
  end
end
