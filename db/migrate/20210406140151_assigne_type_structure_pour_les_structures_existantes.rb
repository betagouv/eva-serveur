class AssigneTypeStructurePourLesStructuresExistantes < ActiveRecord::Migration[6.1]
  class Structure < ApplicationRecord; end

  def up
    Structure.where(type_structure: nil).update_all(type_structure: 'non_communique')
  end

  def down
    Structure.where(type_structure: 'non_communique').update_all(type_structure: nil)
  end
end
