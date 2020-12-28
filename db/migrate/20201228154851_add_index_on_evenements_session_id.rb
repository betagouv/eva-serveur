class AddIndexOnEvenementsSessionId < ActiveRecord::Migration[6.0]
  def change
    add_index :evenements, :session_id
  end
end
