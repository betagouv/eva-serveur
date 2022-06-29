class AddLatitudeLongitudeToStructures < ActiveRecord::Migration[6.1]
  def change
    add_column :structures, :latitude, :float
    add_column :structures, :longitude, :float
    add_index :structures, [:latitude, :longitude]
  end
end
