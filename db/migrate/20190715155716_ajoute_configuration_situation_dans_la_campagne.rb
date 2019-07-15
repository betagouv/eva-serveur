class AjouteConfigurationSituationDansLaCampagne < ActiveRecord::Migration[5.2]
  def change
    create_table :situations_configurations do |t|
      t.belongs_to :campagne, index: true
      t.belongs_to :situation, index: true
      t.integer :position
      t.timestamps
    end
  end
end
