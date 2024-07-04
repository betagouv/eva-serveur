class AjouteColonneSiretAStructure < ActiveRecord::Migration[7.0]
  def change
    add_column :structures, :siret, :string
  end
end
