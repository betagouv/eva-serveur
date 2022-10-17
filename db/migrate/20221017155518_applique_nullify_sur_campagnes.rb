class AppliqueNullifySurCampagnes < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :campagnes, :questionnaires
    add_foreign_key :campagnes, :questionnaires, on_delete: :nullify
  end
end
