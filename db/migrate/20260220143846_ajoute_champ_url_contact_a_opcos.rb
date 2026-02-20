class AjouteChampUrlContactAOpcos < ActiveRecord::Migration[7.2]
  def change
    add_column :opcos, :url_contact, :string
  end
end
