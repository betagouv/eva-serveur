# frozen_string_literal: true

ActiveAdmin.register Beneficiaire do
  filter :nom
  filter :created_at
  config.sort_order = 'created_at_desc'

  permit_params :nom

  before_action only: :show do
    flash.now[:beneficiaire_anonyme] = t('.beneficiaire_anonyme') if resource.anonyme?
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :nom
    end
    f.actions
  end

  show do
    render partial: 'show'
  end

  index do
    column :nom do |beneficiaire|
      render partial: 'nom_beneficiaire', locals: { beneficiaire: beneficiaire }
    end
    column :created_at
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end
end
