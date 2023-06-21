class ChangeCompteIndexWithoutDeleted < ActiveRecord::Migration[7.0]
  def up
    remove_index :comptes, :email
    add_index :comptes, :email, unique: true, where: "deleted_at IS NULL"
  end

  def down
    remove_index :comptes, :email
    add_index :comptes, :email, unique: true
  end
end
