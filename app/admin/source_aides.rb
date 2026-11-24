ActiveAdmin.register SourceAide do
  liste_dsfr

  permit_params :titre, :description, :url, :categorie, :type_document, :position

  filter :titre
  filter :categorie, as: :select
  filter :description
end
