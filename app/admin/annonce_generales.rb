# frozen_string_literal: true

ActiveAdmin.register AnnonceGenerale do
  menu parent: 'Accompagnement'

  permit_params :texte, :afficher

  index do
    column :texte
    column :afficher
    column :created_at
    actions
  end
end
