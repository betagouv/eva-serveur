# frozen_string_literal: true

ActiveAdmin.register Actualite do
  permit_params :titre, :contenu, :categorie

  filter :titre
  filter :contenu
  filter :created_at

  index do
    column(:categorie) { |a| status_tag a.categorie }
    column :titre
    column :created_at
    actions
  end
end
