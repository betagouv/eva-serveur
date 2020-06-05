class AddMetriquesToEvaluation < ActiveRecord::Migration[6.0]
  def change
    add_column :evaluations, :metriques, :jsonb, default: {}
  end
end
