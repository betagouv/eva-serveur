class AjouteParcoursTypePourCampagnes < ActiveRecord::Migration[6.1]
  def change
    add_reference :campagnes, :parcours_type, type: :uuid, index: true
  end
end
