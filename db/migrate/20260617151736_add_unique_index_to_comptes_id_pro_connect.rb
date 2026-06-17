class AddUniqueIndexToComptesIdProConnect < ActiveRecord::Migration[7.2]
  def change
    remove_index :comptes, :id_pro_connect
    add_index :comptes, :id_pro_connect, unique: true, where: "id_pro_connect IS NOT NULL AND deleted_at IS NULL"
  end
end
