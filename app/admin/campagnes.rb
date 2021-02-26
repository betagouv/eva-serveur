# frozen_string_literal: true

ActiveAdmin.register Campagne do
  menu priority: 3

  permit_params :libelle, :code, :questionnaire_id, :compte,
                :compte_id, :affiche_competences_fortes,
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  filter :libelle
  filter :code
  filter :compte, if: proc { can? :manage, Compte }
  filter :situations
  filter :questionnaire
  filter :created_at

  includes :compte

  index do
    column :libelle
    column :code
    column :nombre_evaluations
    column :compte if can?(:manage, Compte)
    column :created_at
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
        c.input :questionnaire
      end
    end
    f.actions
  end

  controller do
    helper_method :statistiques

    private

    def statistiques
      @statistiques ||= StatistiquesCampagne.new(resource)
    end
  end
end
