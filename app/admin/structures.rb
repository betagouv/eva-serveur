# frozen_string_literal: true

ActiveAdmin.register Structure do
  menu parent: 'Terrain'
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
  scope :pas_vraiment_utilisatrices
  scope :non_activees
  scope :actives

  action_item :nouvelle_structure, only: :index do
    link_to I18n.t('admin.structure.nouvelle_structure'), nouvelle_structure_path
  end

  index do
    column :nom
    column(:type_structure) do |structure|
      traduction_type_structure(structure.type_structure)
    end
    column :code_postal
    column :nombre_evaluations do |structure|
      Evaluation.joins(campagne: :compte).where('comptes.structure_id' => structure).count
    end
    column :created_at do |structure|
      l(structure.created_at, format: :court)
    end
    actions
  end

  show do
    render partial: 'show', locals: { structure: resource }
  end

  form partial: 'form'
end
