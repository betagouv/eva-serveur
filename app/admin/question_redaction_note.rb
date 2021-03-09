# frozen_string_literal: true

ActiveAdmin.register QuestionRedactionNote do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :intitule, :illustration, :message,
                :intitule_reponse, :description, :reponse_placeholder

  filter :libelle

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :description
      f.input :intitule
      f.input :intitule_reponse
      f.input :reponse_placeholder
      f.input :illustration, as: :file
    end
    f.actions
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
