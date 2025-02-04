class AjouteOrientationPourQuestion < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :orientation, :string
  end
end
