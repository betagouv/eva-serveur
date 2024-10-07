# frozen_string_literal: true

ActiveAdmin.register SourceAide do
  menu parent: 'Accompagnement'

  permit_params :titre, :description, :url, :categorie, :type_document, :position

  config.filters = false

  index do
    column :titre do |sa|
      link_to sa.titre, admin_source_aide_path(sa)
    end
    column(:categorie) do |a|
      render(Tag.new(t(a.categorie, scope: 'activerecord.attributes.source_aide.categories'),
                     classes: 'tag-categorie source-aide'))
    end
    column :position
    column :description
    column :url do |a|
      link_to a.url, a.url, target: '_blank', rel: 'noopener'
    end
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end
end
