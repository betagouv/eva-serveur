# frozen_string_literal: true

ActiveAdmin.register Campagne do
  permit_params :libelle

  show do
    render partial: 'show', locals: { evaluations: resource.evaluations }
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
    end
    f.actions
  end
end
