class AssigneValeurParDefautPourStructuresExistantes < ActiveRecord::Migration[7.2]
  def up
    Structure.where(autorisation_creation_campagne: nil).update_all(autorisation_creation_campagne: true)
  end

  def down; end
end
