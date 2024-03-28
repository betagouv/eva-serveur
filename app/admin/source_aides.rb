# frozen_string_literal: true

ActiveAdmin.register SourceAide do
  menu parent: 'Accompagnement'

  permit_params :titre, :description, :url, :categorie, :type_document, :position

  config.filters = false

  index do
    column(:categorie) do |a|
      render(Tag.new(t(a.categorie, scope: 'activerecord.attributes.source_aide.categories'),
                     classes: 'tag-categorie'))
    end
    column :position
    column :titre
    column :description
    column :url do |a|
      link_to a.url, a.url, target: '_blank', rel: 'noopener'
    end
    actions
  end
end
