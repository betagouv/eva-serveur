# frozen_string_literal: true

ActiveAdmin.register Beneficiaire do
  filter :nom
  filter :created_at
  config.sort_order = 'created_at_desc'

  permit_params :nom

  show do
    render partial: 'show'
  end

  index do
    column :nom
    column :created_at
    actions
  end
end
