# frozen_string_literal: true

ActiveAdmin.register StructureLocale do
  menu parent: "Terrain", if: proc { current_compte.anlci? }
  actions :all

  permit_params :nom, :type_structure, :code_postal, :parent_id, :siret,
                :autorisation_creation_campagne

  filter :nom
  filter :type_structure,
         as: :select,
         collection: ApplicationController.helpers.collection_types_structures
  filter :code_postal
  filter :region,
         as: :select,
         collection: proc { Structure.distinct.order(:region).pluck(:region) }
  filter :created_at

  scope :all, default: true, if: -> { params[:stats] }
  scope :sans_campagne, if: -> { params[:stats] }
  scope :pas_vraiment_utilisatrices, if: -> { params[:stats] }
  scope :non_activees, if: -> { params[:stats] }
  scope :actives, if: -> { params[:stats] }
  scope :inactives, if: -> { params[:stats] }
  scope :abandonnistes, if: -> { params[:stats] }

  action_item :stats, only: :index do
    if params[:stats]
      link_to t(".sans_stats"), admin_structures_locales_path
    else
      link_to t(".stats"), admin_structures_locales_path(stats: true)
    end
  end

  sidebar :aide_filtres, only: :index, if: -> { params[:stats] }

  index do
    column :nom do |sl|
      link_to sl.nom, admin_structure_locale_path(sl)
    end
    column(:type_structure) do |structure|
      traduction_type_structure(structure.type_structure)
    end
    column :code_postal
    column :created_at do |structure|
      l(structure.created_at, format: :sans_heure)
    end
    column :nombre_evaluations, sortable: :nombre_evaluations
    column :date_derniere_evaluation, sortable: :date_derniere_evaluation
    actions
    column "", class: "bouton-action" do
      render partial: "components/bouton_menu_actions"
    end
  end

  csv do
    column :nom
    column :code_postal
    column :region
    column :type_structure do |structure|
      traduction_type_structure(structure.type_structure)
    end
    column :nombre_evaluations
    column :date_derniere_evaluation
    column "Date de création", &:created_at
  end

  xls do
    whitelist
    column :nom
    column :code_postal
    column :region
    column :type_structure do |structure|
      traduction_type_structure(structure.type_structure)
    end
    column :nombre_evaluations
    column :date_derniere_evaluation
    column "Date de création", &:created_at
  end

  show do
    render partial: "admin/structures/show", locals: { structure: resource }
  end

  form partial: "form"

  controller do
    before_action :trouve_campagnes, only: :show

    def trouve_campagnes
      @campagnes = Campagne.de_la_structure(resource)
    end

    def scoped_collection
      end_of_association_chain.avec_nombre_evaluations_et_date_derniere_evaluation
    end

    def create
      create! do |success, _failure|
        if @current_compte.structure.blank?
          success.html do
            @current_compte.rejoindre_structure(resource)
            redirect_to admin_dashboard_path, notice: I18n.t("nouvelle_structure.bienvenue")
          end
        end
      end
    end
  end
end
