class ChangeColonneTypeDeCompletePourEvaluations < ActiveRecord::Migration[6.1]
  def up
    change_column :evaluations, :complete, :string, default: "incomplete"
  end

  def down
    change_column :evaluations, :complete, "boolean USING CASE WHEN complete = 'true' THEN true ELSE false END"
  end
end
