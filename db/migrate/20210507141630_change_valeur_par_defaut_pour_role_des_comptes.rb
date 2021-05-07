class ChangeValeurParDefautPourRoleDesComptes < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:comptes, :role, from: 'organisation', to: 'conseiller')
  end
end
