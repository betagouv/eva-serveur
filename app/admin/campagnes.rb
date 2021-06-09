# frozen_string_literal: true

ActiveAdmin.register Campagne do
  menu priority: 3

  permit_params :libelle, :code, :questionnaire_id, :compte,
                :compte_id, :affiche_competences_fortes, :parcours_type_id,
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  config.sort_order = 'created_at_desc'

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

  form partial: 'form'

  controller do
    helper_method :statistiques

    before_action :assigne_valeurs_par_defaut, only: %i[new create]
    before_action :parcours_type, only: %i[new create edit update]

    def show
      @statistiques ||= StatistiquesCampagne.new(resource)
      show!
    end

    private

    def find_resource
      scoped_collection.includes(situations_configurations: %i[situation questionnaire])
                       .where(id: params[:id])
                       .first!
    end

    def assigne_valeurs_par_defaut
      params[:campagne] ||= {}
      params[:campagne][:compte_id] ||= current_compte.id
    end

    def parcours_type
      @parcours_type = ParcoursType.includes(situations_configurations: :situation).all
    end
  end
end
