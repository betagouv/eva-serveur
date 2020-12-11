# frozen_string_literal: true

ActiveAdmin.register Aide::QuestionFrequente do
  menu parent: 'Accompagnement'

  permit_params :question, :reponse

  filter :question
  filter :created_at

  index do
    column :question
    column :created_at
    actions
  end
end
