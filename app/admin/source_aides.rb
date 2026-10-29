ActiveAdmin.register SourceAide do
  permit_params :titre, :description, :url, :categorie, :type_document, :position

  filter :titre
  filter :categorie, as: :select
  filter :description

  index dsfr_table: proc { true } do
    column :titre, class: "col-lien-voir" do |sa|
      link_to sa.titre, admin_source_aide_path(sa)
    end
    column(:categorie) do |a|
      render(BadgeComponent.new(
               contenu: t(a.categorie, scope: "activerecord.attributes.source_aide.categories")
             ))
    end
    column :position
    column :description
    column :url do |a|
      link_to a.url, a.url, target: "_blank", rel: "noopener"
    end
    actions
  end
end
