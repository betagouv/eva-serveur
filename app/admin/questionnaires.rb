# frozen_string_literal: true

ActiveAdmin.register Questionnaire do
  permit_params :libelle, questionnaires_questions_attributes: %i[id question_id _destroy]

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.has_many :questionnaires_questions, allow_destroy: true do |c|
        c.input :id, as: :hidden
        c.input :question
      end
    end
    f.actions
  end

  show do
    render partial: 'show'
  end

  controller do
    def scoped_collection
      if current_compte.administrateur?
        Questionnaire.all
      else
        Campagne.includes(:questionnaire).where(compte: current_compte)
      end
    end
  end
end
