# frozen_string_literal: true

ActiveAdmin.register Beneficiaire do
  filter :nom
  filter :created_at
  config.sort_order = 'created_at_desc'

  permit_params :nom

  before_action only: :show do
    flash.now[:beneficiaire_anonyme] = t('.beneficiaire_anonyme') if resource.anonyme?
  end

  show do
    render partial: 'show'
  end

  index do
    column(:nom) { |beneficiaire| nom_pour_ressource(beneficiaire) }
    column :created_at
    actions
  end
end
