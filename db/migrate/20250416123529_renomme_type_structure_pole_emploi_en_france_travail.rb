class RenommeTypeStructurePoleEmploiEnFranceTravail < ActiveRecord::Migration[7.2]
  class StructureLocal < ApplicationRecord; end
  def up
    StructureLocale.where(type_structure: :pole_emploi).update_all(type_structure: :france_travail)
  end

  def down
    StructureLocale.where(type_structure: :france_travail).update_all(type_structure: :pole_emploi)
  end
end
