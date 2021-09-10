# frozen_string_literal: true

ActiveAdmin.register Structure do
  menu parent: 'Terrain', if: proc { can?(:manage, Compte) }
  actions :all, except: [:new]

  permit_params :nom, :type_structure, :code_postal

  filter :nom
  filter :type_structure,
         as: :select,
         collection: ApplicationController.helpers.collection_types_structures
  filter :code_postal
  filter :region,
         as: :select,
         collection: proc { Structure.distinct.order(:region).pluck(:region) }
  filter :created_at

  scope :all
  scope :sans_campagne
  scope :pas_vraiment_utilisatrices
  scope :non_activees
  scope :actives
  scope :inactives
  scope :abandonnistes

  action_item :nouvelle_structure, only: :index do
    link_to I18n.t('admin.structure.nouvelle_structure'), nouvelle_structure_path
  end

  index do
    column :nom
    column(:type_structure) do |structure|
      traduction_type_structure(structure.type_structure)
    end
    column :code_postal
    column :created_at do |structure|
      l(structure.created_at, format: :court)
    end
    column :nombre_evaluations, sortable: :nombre_evaluations
    column :date_derniere_evaluation, sortable: :date_derniere_evaluation
    actions
  end

  show do
    render partial: 'show', locals: { structure: resource }
    active_admin_comments
  end

  sidebar :aide_filtres, only: :index

  form partial: 'form'

  controller do
    before_action :trouve_comptes, :trouve_campagnes, only: :show

    def trouve_comptes
      @comptes = Compte.where(structure: resource)
    end

    def trouve_campagnes
      @campagnes = Campagne.de_la_structure(resource)
    end

    def scoped_collection
      end_of_association_chain.avec_nombre_evaluations_et_date_derniere_evaluation
    end
  end
end
