class AjouteMiseEnActionLeAEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_column :evaluations, :mise_en_action_le, :datetime
  end
end
