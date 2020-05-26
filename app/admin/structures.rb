# frozen_string_literal: true

ActiveAdmin.register Structure do
  permit_params :nom, :code_postal

  actions :all, except: [:new]

  index do
    column :nom
    column :code_postal
    column :nombre_evaluations do |structure|
      Evaluation.joins(campagne: :compte).where('comptes.structure_id' => structure).count
    end
    column :created_at
    actions
  end

  filter :nom
  filter :code_postal
  filter :created_at

  action_item :nouvelle_structure, only: :index do
    link_to I18n.t('admin.structure.nouvelle_structure'), nouvelle_structure_path
  end
end
