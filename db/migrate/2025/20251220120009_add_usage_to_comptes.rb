class AddUsageToComptes < ActiveRecord::Migration[7.2]
  def change
    add_column :comptes, :usage, :string
  end
end
