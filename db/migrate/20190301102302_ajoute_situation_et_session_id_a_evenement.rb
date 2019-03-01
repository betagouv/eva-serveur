class AjouteSituationEtSessionIdAEvenement < ActiveRecord::Migration[5.2]
  def change
    add_column :evenements, :situation, :string
    add_column :evenements, :session_id, :string
  end
end
