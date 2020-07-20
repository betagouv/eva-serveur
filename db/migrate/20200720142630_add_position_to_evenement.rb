class AddPositionToEvenement < ActiveRecord::Migration[6.0]
  def change
    add_column :evenements, :position, :integer
    add_index :evenements, :position
  end
end
