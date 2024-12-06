class AjouteScoreAQuestion < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :score, :float
  end
end
