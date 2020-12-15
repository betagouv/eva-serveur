# frozen_string_literal: true

ActiveAdmin.register Actualite do
  menu priority: 2

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
    render partial: 'show', locals: { autres_actualites: actualite.recentes_sauf_moi(3) }
  end
end
