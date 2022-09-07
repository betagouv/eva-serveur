class AjouteUseragentConditionPassation < ActiveRecord::Migration[7.0]
  def change
    rename_table :conditions_passation, :conditions_passations
    add_column :conditions_passations, :user_agent, :string
    remove_column :conditions_passations, :resolution_ecran, :string
    add_column :conditions_passations, :hauteur_fenetre_navigation, :integer
    add_column :conditions_passations, :largeur_fenetre_navigation, :integer
  end
end
