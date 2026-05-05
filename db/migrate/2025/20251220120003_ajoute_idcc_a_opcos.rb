class AjouteIdccAOpcos < ActiveRecord::Migration[7.2]
  def change
    add_column :opcos, :idcc, :string, array: true, default: []
  end
end
