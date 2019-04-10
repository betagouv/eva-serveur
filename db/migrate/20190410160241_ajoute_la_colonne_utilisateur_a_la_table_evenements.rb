class AjouteLaColonneUtilisateurALaTableEvenements < ActiveRecord::Migration[5.2]
  def change
    add_column :evenements, :utilisateur, :string
  end
end
