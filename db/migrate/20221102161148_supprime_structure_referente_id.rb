class SupprimeStructureReferenteId < ActiveRecord::Migration[7.0]
  def change
    remove_column :structures, :structure_referente_id
  end
end
