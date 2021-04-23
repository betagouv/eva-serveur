class AjouteParcoursTypeIdPourSituationsConfigurations < ActiveRecord::Migration[6.1]
  def change
    add_reference :situations_configurations, :parcours_type, type: :uuid, index: true
  end
end
