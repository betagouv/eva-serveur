class AjouteStructureReferentePourStructures < ActiveRecord::Migration[6.1]
  def change
    add_reference :structures, :structure_referente, type: :uuid, index: true
  end
end
