class AjouteTypeParDefautPourStructuresExistantes < ActiveRecord::Migration[6.1]
  def up
    Structure.where(type: nil).update_all(type: 'StructureLocale')
  end

  def down
    Structure.where(type: 'StructureLocale').update_all(type: nil)
  end
end
