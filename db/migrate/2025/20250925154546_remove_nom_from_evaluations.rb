class RemoveNomFromEvaluations < ActiveRecord::Migration[7.2]
  def change
    remove_column :evaluations, :nom, :string
  end
end
