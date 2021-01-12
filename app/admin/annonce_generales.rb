# frozen_string_literal: true

ActiveAdmin.register AnnonceGenerale do
  menu parent: 'Accompagnement'

  permit_params :texte, :afficher
end
