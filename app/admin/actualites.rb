# frozen_string_literal: true

ActiveAdmin.register Actualite do
  menu priority: 2

  permit_params :titre, :contenu, :categorie, :illustration

  filter :titre
  filter :contenu
  filter :created_at

  config.sort_order = "created_at_desc"

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :illustration, as: :file
      f.input :titre
      f.input :contenu
      f.input :categorie
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    render partial: "actualites", locals: { actualites: actualites }
  end

  show do
    render partial: "show"
  end

  sidebar :details_actualite, class: "details-actualite annule-panel", only: :show

  sidebar :autres_actualites, class: "autres-actualites annule-carte", only: :show do
    render partial: "autres_actualites_sidebar",
           locals: { autres_actualites: actualite.recentes_sauf_moi(3) }
  end
end
