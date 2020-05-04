# frozen_string_literal: true

ActiveAdmin.register Structure do
  permit_params :nom, :code_postal

  index do
    column :nom
    column :code_postal
    column :created_at
    actions
  end
end
