# frozen_string_literal: true

class AddRoleToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :role, :string, null: false, default: "conseiller"
  end
end
