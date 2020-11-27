# frozen_string_literal: true

ActiveAdmin.register Actualite do
  permit_params :titre, :contenu, :categorie

  filter :titre
  filter :contenu
  filter :created_at

  config.sort_order = 'created_at_desc'

  index do
    column(:categorie) { |a| status_tag a.categorie }
    column :titre
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
