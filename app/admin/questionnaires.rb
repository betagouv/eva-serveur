# frozen_string_literal: true

ActiveAdmin.register Questionnaire do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique,
                questionnaires_questions_attributes: %i[id question_id _destroy]

  filter :questions

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
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
    column :nom_technique
    column :created_at
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end

  show do
    render partial: 'show'
  end

  controller do
    def find_resource
      scoped_collection.where(id: params[:id]).includes(questionnaires_questions: :question).first!
    end
  end
end
