class AjouteActivePourCampagnes < ActiveRecord::Migration[7.2]
  def change
    add_column :campagnes, :active, :boolean, default: true
    add_index :campagnes, :active
  end
end
