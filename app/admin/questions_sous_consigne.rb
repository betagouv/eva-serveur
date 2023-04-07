# frozen_string_literal: true

ActiveAdmin.register QuestionSousConsigne do
  menu parent: 'Parcours', if: proc { current_compte.superadmin? }

  permit_params :libelle, :nom_technique, :intitule

  filter :libelle

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
      f.input :intitule
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle
    column :intitule
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
