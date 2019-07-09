# frozen_string_literal: true

ActiveAdmin.register Campagne do
  permit_params :libelle, :code

  show do
    render partial: 'show', locals: { evaluations: resource.evaluations }
  end
end
