# frozen_string_literal: true

ActiveAdmin.register SourceAide do
  menu parent: 'Accompagnement'

  permit_params :titre, :description, :url, :categorie, :type_document

  config.filters = false

  index do
    column(:categorie) do |a|
      render 'components/tag', contenu: t(".categories.#{a.categorie}")
    end
    column :titre
    column :description
    column :url do |a|
      link_to a.url, a.url, target: '_blank', rel: 'noopener'
    end
    actions
  end
end
