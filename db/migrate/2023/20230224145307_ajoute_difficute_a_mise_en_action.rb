class AjouteDifficuteAMiseEnAction < ActiveRecord::Migration[7.0]
  def change
    add_column :mises_en_action, :difficulte, :string
  end
end
