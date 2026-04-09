class AjouteCodeCommuneAStructure < ActiveRecord::Migration[7.2]
  def change
    add_column :structures, :code_commune, :string
  end
end
