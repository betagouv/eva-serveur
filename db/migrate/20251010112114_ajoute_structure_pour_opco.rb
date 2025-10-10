class AjouteStructurePourOpco < ActiveRecord::Migration[7.2]
  def change
    add_reference :structures, :opco, type: :uuid, foreign_key: true
  end
end
