class RenomeColonnesTypeEvenementEtDescriptionPourEvenement < ActiveRecord::Migration[5.2]
  def change
    rename_column :evenements, :type_evenement, :nom
    rename_column :evenements, :description, :donnees
  end
end
