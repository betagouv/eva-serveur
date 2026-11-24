ActiveAdmin.register AnnonceGenerale do
  # La position dans le menu est gérée par NavigationComponent

  liste_dsfr

  config.sort_order = "created_at_desc"

  permit_params :texte, :afficher

  filter :texte
  filter :afficher, as: :boolean
  filter :created_at
end
