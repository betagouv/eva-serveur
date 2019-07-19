# frozen_string_literal: true

ActiveAdmin.register QuestionRedactionNote do
  menu parent: 'Questions'

  permit_params :intitule, :entete_reponse, :expediteur, :message, :objet_reponse

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :intitule
      f.input :entete_reponse
      f.input :expediteur
      f.input :message
      f.input :objet_reponse
    end
    f.actions
  end

  index do
    selectable_column
    column :id
    column :intitule
    column :entete_reponse
    column :expediteur
    column :message
    column :objet_reponse
    column :created_at
    column :updated_at
    actions
  end

  show do
    render partial: 'show'
  end
end
