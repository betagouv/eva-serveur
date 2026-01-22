class AjoutePassableAQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :passable, :boolean, default: false
  end
end
