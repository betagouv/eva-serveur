class AjouteTexteATrouAQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :texte_a_trous, :text
  end
end
