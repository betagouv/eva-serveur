class CreeNouvellesStructuresOpco < ActiveRecord::Migration[7.2]
  def up
    StructureAdministrative.where(usage: AvecUsage::USAGE_EVAPRO).update_all(type: "StructureOpco", usage: AvecUsage::USAGE_BENEFICIAIRES)
  end

  def down
    StructureOpco.update_all(type: "StructureAdministrative", usage: AvecUsage::USAGE_EVAPRO)
  end
end
