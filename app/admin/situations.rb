# frozen_string_literal: true

ActiveAdmin.register Situation do
  permit_params :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id

  form do |f|
    f.semantic_errors
    inputs do
      f.input :libelle
      f.input :nom_technique
      f.input :questionnaire
      f.input :questionnaire_entrainement
    end
    f.actions
  end
end
