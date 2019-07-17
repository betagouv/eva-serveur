# frozen_string_literal: true

ActiveAdmin.register Questionnaire do
  permit_params :libelle, question_ids: []

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :questions, as: :check_boxes
    end
    f.actions
  end

  show do
    render partial: 'show'
  end
end
