ActiveAdmin.register AnnonceGenerale do
  # La position dans le menu est gérée par NavigationComponent

  liste_dsfr { |parametres| Referentiels::FiltresListe.new(parametres) }

  config.sort_order = "created_at_desc"

  permit_params :texte, :afficher
end
