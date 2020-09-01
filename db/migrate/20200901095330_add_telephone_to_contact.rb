class AddTelephoneToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :telephone, :string
  end
end
