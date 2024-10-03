# frozen_string_literal: true

ActiveAdmin.register QuestionGlisserDeposer do
  before_action :set_question, only: %i[update]

  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique, :description, :illustration, :supprimer_illustration,
                :supprimer_audio_modalite_reponse, :supprimer_audio_intitule,
                :supprimer_zone_depot, :zone_depot,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy],
                reponses_attributes: %i[id illustration position type_choix position_client
                                        nom_technique _destroy]

  filter :libelle
  filter :nom_technique

  form partial: 'form'

  index do
    column :libelle
    column :intitule do |question|
      question.transcription_intitule&.ecrit
    end
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end

  controller do
    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end
  end
end
