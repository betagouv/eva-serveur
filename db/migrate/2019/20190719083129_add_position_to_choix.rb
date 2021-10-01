class AddPositionToChoix < ActiveRecord::Migration[5.2]
  def change
    add_column :choix, :position, :integer
  end
end
