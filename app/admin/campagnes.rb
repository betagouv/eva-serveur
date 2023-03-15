# frozen_string_literal: true

ActiveAdmin.register Campagne do
  menu priority: 3

  permit_params :libelle, :code, :compte,
                :compte_id, :affiche_competences_fortes, :parcours_type_id, :type_programme,
                options_personnalisation: [],
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  config.sort_order = 'created_at_desc'

  filter :libelle
  filter :code
  filter :compte_id,
         as: :search_select_filter,
         url: proc { admin_comptes_path },
         fields: %i[email nom prenom],
         display_name: 'display_name',
         minimum_input_length: 2,
         order_by: 'email_asc',
         if: proc { can? :manage, Compte }
  filter :situations
  filter :created_at

  action_item :voir_evaluations, only: :show do
    link_to I18n.t('admin.campagnes.action_items.voir_evaluations',
                   count: Evaluation.where(campagne: resource).count),
            admin_evaluations_path(q: { campagne_id_eq: resource })
  end

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
    before_action :assigne_valeurs_par_defaut, only: %i[new create]
    before_action :parcours_type, only: %i[new create edit update]
    before_action :situations_configurations, only: %i[show]

    def create
      create!
      flash[:notice] = I18n.t('admin.campagnes.show.nouvelle_campagne') if resource.save
    end

    def show
      show!
    end

    private

    def scoped_collection
      if can?(:manage, Compte)
        end_of_association_chain.includes(:compte)
      else
        end_of_association_chain
      end
    end

    def find_resource
      scoped_collection.where(id: params[:id])
                       .first!
    end

    def assigne_valeurs_par_defaut
      params[:campagne] ||= {}
      params[:campagne][:compte_id] ||= current_compte.id
    end

    def parcours_type
      @parcours_type = ParcoursType.order(:created_at)
    end

    def situations_configurations
      @situations_configurations ||= resource
                                     .situations_configurations
                                     .includes([:questionnaire,
                                                { situation: %i[questionnaire
                                                                illustration_attachment] }])
    end
  end
end
