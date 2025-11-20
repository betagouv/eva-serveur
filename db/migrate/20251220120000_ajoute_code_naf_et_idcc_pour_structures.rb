class AjouteCodeNafEtIdccPourStructures < ActiveRecord::Migration[7.0]
  def change
    add_column :structures, :code_naf, :string
    add_column :structures, :idcc, :string, array: true, default: []
  end
end


