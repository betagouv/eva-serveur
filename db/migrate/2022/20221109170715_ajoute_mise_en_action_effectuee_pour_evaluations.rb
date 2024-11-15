class AjouteMiseEnActionEffectueePourEvaluations < ActiveRecord::Migration[7.0]
  def change
    add_column :evaluations, :mise_en_action_effectuee, :boolean
  end
end
