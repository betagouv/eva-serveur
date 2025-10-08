class AjouteRedactionsAEvaluations < ActiveRecord::Migration[7.2]
  def change
    add_column :evaluations, :redactions, :jsonb
  end
end
