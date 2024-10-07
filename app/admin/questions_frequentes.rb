# frozen_string_literal: true

ActiveAdmin.register Aide::QuestionFrequente do
  menu parent: 'Accompagnement'

  permit_params :question, :reponse

  filter :question
  filter :created_at

  index do
    column :question do |q|
      link_to q.question, admin_aide_question_frequente_path(q)
    end
    column :created_at
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end
end
