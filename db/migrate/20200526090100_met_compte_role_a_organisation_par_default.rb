class MetCompteRoleAOrganisationParDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :comptes, :role, 'organisation'
  end
end
