class RenommeAdministrateursToComptes < ActiveRecord::Migration[5.2]
  def change
    rename_table :administrateurs, :comptes
  end
end
