# frozen_string_literal: true

ActiveAdmin.register QuestionSaisie do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :categorie, :libelle, :nom_technique, :intitule, :message,
                :suffix_reponse, :description, :reponse_placeholder

  filter :libelle

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :categorie, as: :select
      f.input :nom_technique
      f.input :description
      f.input :intitule
      f.input :suffix_reponse
      f.input :reponse_placeholder
      f.input :type_saisie
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle
    column :categorie
    column :intitule
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
