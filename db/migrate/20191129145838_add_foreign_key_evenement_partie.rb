class AddForeignKeyEvenementPartie < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :evenements, :parties, on_delete: :cascade, column: 'session_id', primary_key: 'session_id'
  end
end
