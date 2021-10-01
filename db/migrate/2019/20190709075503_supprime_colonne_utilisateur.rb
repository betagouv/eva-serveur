class SupprimeColonneUtilisateur < ActiveRecord::Migration[5.2]
  def change
    remove_column :evenements, :utilisateur, :string
  end
end
