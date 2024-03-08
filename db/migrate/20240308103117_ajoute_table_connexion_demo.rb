class AjouteTableConnexionDemo < ActiveRecord::Migration[7.0]
  def change
    create_table :connexions_demo, id: :uuid do |t|
      t.timestamps
    end
  end
end
