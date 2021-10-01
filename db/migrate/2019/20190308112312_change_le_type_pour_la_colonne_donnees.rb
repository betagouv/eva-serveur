class ChangeLeTypePourLaColonneDonnees < ActiveRecord::Migration[5.2]
  def change
    change_column :evenements, :donnees, :jsonb, null: false, default: '{}', using: "donnees::jsonb"
  end
end
