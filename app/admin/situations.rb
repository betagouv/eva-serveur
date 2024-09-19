# frozen_string_literal: true

ActiveAdmin.register Situation do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id,
                :description, :illustration

  includes :questionnaire, :questionnaire_entrainement, illustration_attachment: :blob

  form do |f|
    f.semantic_errors
    inputs do
      f.input :libelle
      f.input :nom_technique
      f.input :illustration, as: :file
      f.input :description, as: :text
      f.input :questionnaire
      f.input :questionnaire_entrainement
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :illustration do |situation|
      situation_illustration(situation)
    end
    column :libelle
    column :nom_technique
    column :questionnaire
    column :questionnaire_entrainement
    actions do |situation|
      link_to 'Parties', admin_situation_parties_path(situation) if can?(:manage, Partie)
    end
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end

  show do
    render 'show'
  end
end
