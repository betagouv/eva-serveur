class AddTelephoneToCompte < ActiveRecord::Migration[6.1]
  def change
    add_column :comptes, :telephone, :string
  end
end
