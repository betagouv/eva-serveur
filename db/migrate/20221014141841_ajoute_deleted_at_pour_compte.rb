class AjouteDeletedAtPourCompte < ActiveRecord::Migration[7.0]
  def change
    add_column :comptes, :deleted_at, :datetime
    add_index :comptes, :deleted_at
  end
end
