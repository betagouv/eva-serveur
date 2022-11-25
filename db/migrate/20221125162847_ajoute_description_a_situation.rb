class AjouteDescriptionASituation < ActiveRecord::Migration[7.0]
  def change
    add_column :situations, :description, :text
  end
end
