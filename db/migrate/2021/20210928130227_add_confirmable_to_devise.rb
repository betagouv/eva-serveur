class AddConfirmableToDevise < ActiveRecord::Migration[6.1]
  def change
    add_column :comptes, :confirmation_token, :string
    add_column :comptes, :confirmed_at, :datetime
    add_column :comptes, :confirmation_sent_at, :datetime
    add_column :comptes, :unconfirmed_email, :string
    add_index :comptes, :confirmation_token, unique: true
  end
end
