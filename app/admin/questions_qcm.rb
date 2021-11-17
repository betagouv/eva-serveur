# frozen_string_literal: true

ActiveAdmin.register QuestionQcm do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique, :intitule, :description,
                :metacompetence, :type_qcm,
                choix_attributes: %i[id intitule type_choix _destroy nom_technique]

  filter :intitule

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
      f.input :intitule
      f.input :metacompetence
      f.input :type_qcm
      f.input :description
      f.has_many :choix, allow_destroy: ->(choix) { can? :destroy, choix } do |c|
        c.input :id, as: :hidden
        c.input :intitule
        c.input :nom_technique
        c.input :type_choix
      end
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle
    column :intitule
    column :metacompetence
    column :type_qcm
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
