# frozen_string_literal: true

ActiveAdmin.register ParcoursType do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique, :duree_moyenne, :description, :categorie,
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  filter :libelle
  filter :nom_technique
  filter :created_at
  filter :description

  form partial: 'form'

  index do
    column :libelle
    column :nom_technique
    column :duree_moyenne
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
