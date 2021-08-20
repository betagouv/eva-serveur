# frozen_string_literal: true

ActiveAdmin.register SourceAide do
  menu parent: 'Accompagnement'

  permit_params :titre, :description, :url, :categorie, :type_document

  config.filters = false

  index do
    column(:categorie) { |a| status_tag a.categorie }
    column :titre
    column :description
    column :url do |a|
      link_to a.url, a.url, target: '_blank', rel: 'noopener'
    end
    actions
  end
end
