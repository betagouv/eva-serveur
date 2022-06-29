class AjouteRegionPourStructures < ActiveRecord::Migration[6.1]
  def change
    add_column :structures, :region, :string
  end
end
