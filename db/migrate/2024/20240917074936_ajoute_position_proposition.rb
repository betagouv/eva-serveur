class AjoutePositionProposition < ActiveRecord::Migration[7.0]
  def change
    add_column :choix, :position_client, :integer
  end
end
