class AjouteEvaluation < ActiveRecord::Migration[5.2]
  def change
    create_table :evaluations do |t|
      t.string "nom"
      t.timestamps
    end

    add_reference :evenements, :evaluation
  end
end
