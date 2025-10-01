ActiveAdmin.register AnnonceGenerale do
  menu parent: "Accompagnement"

  config.sort_order = "created_at_desc"

  permit_params :texte, :afficher

  filter :texte
  filter :afficher, as: :boolean
  filter :created_at

  index do
    column :texte do |ag|
      link_to ag.texte, admin_annonce_generale_path(ag)
    end
    column :afficher
    column :created_at
    actions
  end
end
