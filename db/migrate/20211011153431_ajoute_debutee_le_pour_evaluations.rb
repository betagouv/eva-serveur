class AjouteDebuteeLePourEvaluations < ActiveRecord::Migration[6.1]
  def change
    add_column :evaluations, :debutee_le, :datetime
  end
end
