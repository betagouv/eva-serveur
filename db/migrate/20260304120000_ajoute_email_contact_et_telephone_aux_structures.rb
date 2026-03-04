# frozen_string_literal: true

class AjouteEmailContactEtTelephoneAuxStructures < ActiveRecord::Migration[7.2]
  def change
    add_column :structures, :email_contact, :string
    add_column :structures, :telephone, :string
  end
end
