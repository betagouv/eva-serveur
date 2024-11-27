class AjouteAidePourQuestion < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :aide, :text
  end
end
