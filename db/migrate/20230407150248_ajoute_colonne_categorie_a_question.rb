class AjouteColonneCategorieAQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :categorie, :string
  end
end
