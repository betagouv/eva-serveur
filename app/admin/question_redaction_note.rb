# frozen_string_literal: true

ActiveAdmin.register QuestionRedactionNote do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique, :intitule, :message,
                :intitule_reponse, :description, :reponse_placeholder

  filter :libelle

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
      f.input :description
      f.input :intitule
      f.input :intitule_reponse
      f.input :reponse_placeholder
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle
    column :intitule
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
