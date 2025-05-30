class AjoutePriveePourCampagne < ActiveRecord::Migration[7.2]
  def change
    add_column :campagnes, :privee, :boolean, default: false
    add_index :campagnes, :privee
  end
end
