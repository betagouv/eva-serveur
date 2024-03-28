class AjouteColonnePositionASourceAides < ActiveRecord::Migration[7.0]
  def change
    add_column :source_aides, :position, :integer, default: 0
  end
end
