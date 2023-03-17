class AjouteTypeSaisieQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :type_saisie, :integer, default: 0
    rename_column :questions, :intitule_reponse, :suffix_reponse
  end
end
