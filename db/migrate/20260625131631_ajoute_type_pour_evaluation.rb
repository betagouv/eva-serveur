class AjouteTypePourEvaluation < ActiveRecord::Migration[7.2]
  def change
    add_column :evaluations, :type, :string
    add_index :evaluations, :type
  end
end
