class AddIndexToEvenements < ActiveRecord::Migration[6.1]
  def change
    add_index :evenements, [:session_id, :position], name: "index_evenements_on_session_id_and_position"
  end
end
