class AjouteDeviseTrackablePourComptes < ActiveRecord::Migration[6.1]
  def change
    add_column :comptes, :sign_in_count, :integer, default: 0, null: false
    add_column :comptes, :current_sign_in_at, :datetime
    add_column :comptes, :last_sign_in_at, :datetime
    add_column :comptes, :current_sign_in_ip, :string
    add_column :comptes, :last_sign_in_ip, :string
  end
end
