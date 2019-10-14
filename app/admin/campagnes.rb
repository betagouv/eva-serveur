# frozen_string_literal: true

ActiveAdmin.register Campagne do
  permit_params :libelle, :code, :questionnaire_id, :compte, :compte_id,
                situations_configurations_attributes: %i[id situation_id _destroy]

  filter :compte, if: proc { can? :manage, Compte }
  filter :situations
  filter :questionnaire

  index do
    selectable_column
    column :libelle
    column :code
    column t('.nombre_participants') do |campagne|
      nombre_participants campagne
    end
    column :compte if can?(:manage, Compte)
    actions
  end

  show do
    render partial: 'show'
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :compte if can?(:manage, Compte)
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

  controller do
    helper_method :nombre_participants

    def create
      params[:campagne][:compte_id] ||= current_compte.id
      create!
    end

    def nombre_participants(campagne)
      Evaluation.where(campagne: campagne).count
    end
  end
end
