class RemoveLatitudeLongitudeFromStructures < ActiveRecord::Migration[7.2]
  def change
    remove_column :structures, :latitude, :float
    remove_column :structures, :longitude, :float
  end
end
