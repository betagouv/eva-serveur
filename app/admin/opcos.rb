ActiveAdmin.register Opco do
  permit_params :nom, :financeur, :logo, :telephone, :url, :email, :url_contact,
                :visuel_offre_services, :supprimer_visuel_offre_services, :url_offre_services,
                :idcc_texte,
                opco_parcours_types_attributes: [
                  :id, :parcours_type_id, :_destroy
                ]

  filter :nom
  filter :financeur

  index dsfr_table: proc { true } do
    column :nom do |opco|
      libelle = opco.nom
      if opco.logo.attached?
        logo = image_tag(cdn_for(opco.logo.variant(:defaut)),
                         alt: opco.logo.filename,
                         class: "logo-opco-preview")
        libelle = logo + " " + libelle
      end
      link_to libelle, admin_opco_path(opco)
    end
    column :financeur do |opco|
      badge_financeur(opco)
    end
    column :created_at
    actions
  end

  show do
    render partial: "show"
  end

  form partial: "form"
end
