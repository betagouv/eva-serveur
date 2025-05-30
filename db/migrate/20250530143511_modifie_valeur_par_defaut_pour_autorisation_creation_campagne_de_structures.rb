class ModifieValeurParDefautPourAutorisationCreationCampagneDeStructures < ActiveRecord::Migration[7.2]
  def change
    change_column :structures, :autorisation_creation_campagne, :boolean, default: true
  end
end
