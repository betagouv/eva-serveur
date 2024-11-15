class AjouteTexteSurIllustrationPourQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :texte_sur_illustration, :text
  end
end
