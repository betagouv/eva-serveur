# frozen_string_literal: true

ActiveAdmin.register Questionnaire do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, questionnaires_questions_attributes: %i[id question_id _destroy]

  filter :questions

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.has_many :questionnaires_questions, allow_destroy: true do |c|
        c.input :id, as: :hidden
        c.input :question
      end
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
