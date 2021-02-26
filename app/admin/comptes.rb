# frozen_string_literal: true

ActiveAdmin.register Compte do
  menu parent: 'Terrain'

  permit_params :email, :password, :password_confirmation, :role, :structure_id

  includes :structure

  index do
    column :email
    column :role
    column :structure
    column :created_at
    column :access_locked?
    actions
  end

  filter :email
  filter :structure
  filter :created_at
  filter :locked_at

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

  controller do
    def update_resource(object, attributes)
      update_method = if attributes.first[:password].present?
                        :update
                      else
                        :update_without_password
                      end
      object.send(update_method, *attributes)
    end
  end

  show do
    render 'show'
  end
end
