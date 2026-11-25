ActiveAdmin.register Opco do
  liste_dsfr { |parametres| Referentiels::FiltresListe.new(parametres) }

  permit_params :nom, :financeur, :logo, :telephone, :url, :email, :url_contact,
                :visuel_offre_services, :supprimer_visuel_offre_services, :url_offre_services,
                :idcc_texte,
                opco_parcours_types_attributes: [
                  :id, :parcours_type_id, :_destroy
                ]

  show do
    render partial: "show"
  end

  form partial: "form"
end
