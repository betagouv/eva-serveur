ActiveAdmin.register Opco do
  menu parent: I18n.t(".menu_structure"), if: proc { current_compte.superadmin? }

  permit_params :nom, :financeur, :logo, :telephone, :url, :email, :url_contact,
                :visuel_offre_services, :supprimer_visuel_offre_services, :url_offre_services,
                :idcc_texte

  filter :nom
  filter :financeur

  index do
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

  form do |f|
    f.inputs do
      f.input :nom, hint: I18n.t("formtastic.hints.opco.nom")
      f.input :financeur, as: :toggle
      f.input :logo, as: :image_file
      f.input :telephone
      f.input :email
      f.input :url
      f.input :url_contact
      f.object.idcc_texte = f.object.idcc.join(", ")
      f.input :idcc_texte,
              label: Opco.human_attribute_name(:idcc),
              as: :string,
              hint: I18n.t("formtastic.hints.opco.idcc")
      f.input :url_offre_services
      render partial: "admin/opcos/form_visuel_offre_services", locals: { f: f }
    end
    f.actions
  end
end
