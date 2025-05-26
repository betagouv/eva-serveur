class AjouteDroitCreationCampagnePourConseiller < ActiveRecord::Migration[7.2]
  def change
    add_column :structures, :autorisation_creation_campagne, :boolean, default: false
  end
end
