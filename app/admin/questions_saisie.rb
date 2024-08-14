# frozen_string_literal: true

ActiveAdmin.register QuestionSaisie do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :categorie, :libelle, :nom_technique, :message,
                :suffix_reponse, :description, :reponse_placeholder, :type_saisie,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy],
                choix_attributes: %i[id intitule audio type_choix _destroy nom_technique]

  filter :libelle

  form partial: 'form'

  index do
    column :libelle
    column :categorie
    column :intitule do |question|
      question.transcription_ecrite_pour(:intitule)
    end
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
