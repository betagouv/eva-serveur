class RemoveSituationFromEvenement < ActiveRecord::Migration[5.2]
  def change
    remove_column :evenements, :situation, :string
  end
end
