class SupprimeMiseEnActionEvaluations < ActiveRecord::Migration[7.0]
  def change
    remove_column :evaluations, :mise_en_action_le, :datetime
    remove_column :evaluations, :mise_en_action_effectuee, :boolean
  end
end
