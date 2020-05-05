# frozen_string_literal: true

ActiveAdmin.register Structure do
  permit_params :nom, :code_postal

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
end
