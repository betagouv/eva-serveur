# frozen_string_literal: true

ActiveAdmin.register Situation do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

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

  index do
    column :libelle
    column :nom_technique
    column :questionnaire
    column :questionnaire_entrainement
    actions do |situation|
      link_to 'Parties', admin_situation_parties_path(situation) if can?(:manage, Partie)
    end
  end
end
