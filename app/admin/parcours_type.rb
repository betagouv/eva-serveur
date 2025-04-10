# frozen_string_literal: true

ActiveAdmin.register ParcoursType do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :actif, :position, :nom_technique,
                :duree_moyenne, :description, :type_de_programme,
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  filter :libelle
  filter :nom_technique
  filter :type_de_programme, as: :select
  filter :created_at
  filter :description

  form partial: 'form'

  index do
    column :libelle do |pt|
      link_to pt.libelle, admin_parcours_type_path(pt)
    end
    column :actif
    column :position
    column :nom_technique
    column :type_de_programme
    column :created_at
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end

  show do
    render partial: 'show'
  end
end
