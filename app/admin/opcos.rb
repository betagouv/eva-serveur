ActiveAdmin.register Opco do
  menu parent: I18n.t(".menu_structure"), if: proc { current_compte.superadmin? }

  permit_params :nom, :financeur, :logo, :telephone, :url, :email

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
    end
    f.actions
  end
end
