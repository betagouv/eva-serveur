# frozen_string_literal: true

ActiveAdmin.register Actualite do
  permit_params :titre, :contenu, :categorie, :illustration

  filter :titre
  filter :contenu
  filter :created_at

  config.sort_order = 'created_at_desc'

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :illustration, as: :file
      f.input :titre
      f.input :contenu
      f.input :categorie
    end
    f.actions
  end

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
