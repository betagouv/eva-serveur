class RetireNombreEvaluationsDeCampagne < ActiveRecord::Migration[7.0]
  def change
    remove_column :campagnes, :nombre_evaluations, :integer
  end
end
