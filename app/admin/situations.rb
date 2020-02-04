# frozen_string_literal: true

ActiveAdmin.register Situation do
  permit_params :libelle, :nom_technique, :questionnaire_id
end
