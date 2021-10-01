class AjouteIndexUniqueSessionId < ActiveRecord::Migration[6.0]
  def change
    add_index :parties, :session_id, unique: true
  end
end
