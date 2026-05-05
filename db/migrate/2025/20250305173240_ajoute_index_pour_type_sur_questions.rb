class AjouteIndexPourTypeSurQuestions < ActiveRecord::Migration[7.2]
  def change
    add_index :questions, :type
  end
end
