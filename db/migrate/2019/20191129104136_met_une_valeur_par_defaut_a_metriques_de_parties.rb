class MetUneValeurParDefautAMetriquesDeParties < ActiveRecord::Migration[6.0]
  def change
    change_column_default :parties, :metriques, {}
  end
end
