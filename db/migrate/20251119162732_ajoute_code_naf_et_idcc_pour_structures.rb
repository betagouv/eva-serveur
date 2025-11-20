class AjouteCodeNafEtIdccPourStructures < ActiveRecord::Migration[7.2]
  def change
    add_column :structures, :code_naf, :string
    add_column :structures, :idcc, :string
  end
end

