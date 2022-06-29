class AjouteTypeStruturePourStructures < ActiveRecord::Migration[6.1]
  def change
    add_column :structures, :type_structure, :string
  end
end
