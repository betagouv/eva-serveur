class AddCampagneToEvaluation < ActiveRecord::Migration[5.2]
  def change
    add_reference :evaluations, :campagne, foreign_key: true
  end
end
