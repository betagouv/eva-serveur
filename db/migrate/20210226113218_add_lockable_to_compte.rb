class AddLockableToCompte < ActiveRecord::Migration[6.1]
  def change
    add_column :comptes, :failed_attempts, :integer
    add_column :comptes, :unlock_token, :string
    add_column :comptes, :locked_at, :datetime
    add_index :comptes, :unlock_token,         unique: true
  end
end
