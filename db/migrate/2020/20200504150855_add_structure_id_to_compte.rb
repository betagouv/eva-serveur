class AddStructureIdToCompte < ActiveRecord::Migration[6.0]
  def change
    add_reference :comptes, :structure, foreign_key: true, type: :uuid
  end
end
