class DropTableMiseEnAction < ActiveRecord::Migration[6.0]
  def change
    drop_table :mises_en_action
  end
end
