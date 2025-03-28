class SupprimeIndexInutileDeEvenements < ActiveRecord::Migration[7.2]
  def change
    remove_index :evenements, :session_id
  end
end
