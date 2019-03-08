# frozen_string_literal: true

ActiveAdmin.register Evenement do
  permit_params :donnees, :session_id, :situation, :nom, :date

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

  form do |f|
    f.inputs do
      f.input :session_id
      f.input :situation
      f.input :nom
      f.input :donnees, as: :text
      f.input :date, as: :datepicker
    end
    f.actions
  end
end
