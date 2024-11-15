class AjouteModeTutorielPourCompte < ActiveRecord::Migration[7.0]
  def change
    add_column :comptes, :mode_tutoriel, :boolean, default: true
  end
end
