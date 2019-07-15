# frozen_string_literal: true

ActiveAdmin.register Campagne do
  permit_params :libelle, :code, :questionnaire_id

  sidebar 'Configuration', only: %i[show edit] do
    link_to 'Configuration', admin_campagne_situations_configurations_path(resource)
  end

  show do
    render partial: 'show', locals: { evaluations: resource.evaluations }
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :code
      f.input :questionnaire
    end
    f.actions
  end
end
