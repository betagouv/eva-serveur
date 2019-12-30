# frozen_string_literal: true

ActiveAdmin.register Campagne do
  config.batch_actions = false
  permit_params :libelle, :code, :questionnaire_id, :compte,
                :compte_id, :affiche_competences_fortes,
                situations_configurations_attributes: %i[id situation_id _destroy]

  filter :compte, if: proc { can? :manage, Compte }
  filter :situations
  filter :questionnaire

  includes :compte

  action_item :csv, only: :show do
    link_to 'Télécharger les événements',
            admin_evenements_path(q: { campagne: resource.code }, format: :csv)
  end

  index do
    selectable_column
    column :libelle
    column :code
    column :nombre_evaluations
    column :compte if can?(:manage, Compte)
    actions
  end

  show do
    render partial: 'show'
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :compte if can?(:manage, Compte)
      f.input :libelle
      f.input :code
      f.input :affiche_competences_fortes
      f.input :questionnaire
      f.has_many :situations_configurations, allow_destroy: true do |c|
        c.input :id, as: :hidden
        c.input :situation
      end
    end
    f.actions
  end

  controller do
    def create
      params[:campagne][:compte_id] ||= current_compte.id
      create!
    end
  end
end
