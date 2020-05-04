# frozen_string_literal: true

ActiveAdmin.register Compte do
  permit_params :email, :password, :password_confirmation, :role, :structure_id

  includes :structure

  index do
    selectable_column
    column :email
    column :role
    column :structure
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :role, as: :select, collection: %w[administrateur organisation]
      f.input :structure
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
