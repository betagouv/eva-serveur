ActiveAdmin.register SourceAide do
  liste_dsfr { |parametres| Referentiels::FiltresListe.new(parametres) }

  permit_params :titre, :description, :url, :categorie, :type_document, :position
end
