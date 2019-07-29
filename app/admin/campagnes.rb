# frozen_string_literal: true

ActiveAdmin.register Campagne do
  permit_params :libelle, :code, :questionnaire_id, :compte, :compte_id,
                situations_configurations_attributes: %i[id situation_id _destroy]

  show do
    render partial: 'show'
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      if current_compte.administrateur?
        f.input :compte
      else
        f.object.compte_id ||= current_compte.id
        f.input :compte_id, as: :hidden
      end
      f.input :libelle
      f.input :code
      f.input :questionnaire
      f.has_many :situations_configurations, allow_destroy: true do |c|
        c.input :id, as: :hidden
        c.input :situation
      end
    end
    f.actions
  end
end
