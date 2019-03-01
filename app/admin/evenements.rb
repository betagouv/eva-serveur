# frozen_string_literal: true

ActiveAdmin.register Evenement do
  permit_params :type_evenement, :description

  filter :situation, as: :select
  filter :session_id
  filter :date

  index do
    selectable_column
    column :id
    column :session_id
    column :situation
    column :nom
    column :donnees
    column :date
    column :created_at
    column :updated_at
    actions
  end
end
