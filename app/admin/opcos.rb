ActiveAdmin.register Opco do
  menu parent: I18n.t(".menu_structure"), if: proc { current_compte.superadmin? }

  permit_params :nom, :financeur

  filter :nom
  filter :financeur

  index do
    column :nom
    column :financeur do |opco|
      badge_financeur(opco)
    end
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :nom, hint: I18n.t("formtastic.hints.opco.nom")
      f.input :financeur, as: :toggle
    end
    f.actions
  end
end
