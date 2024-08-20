# frozen_string_literal: true

ActiveAdmin.register QuestionQcm do
  before_action :set_question, only: %i[update]

  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :categorie, :libelle, :nom_technique, :description,
                :metacompetence, :type_qcm, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :supprimer_audio_modalite_reponse,
                choix_attributes: %i[id intitule audio type_choix _destroy nom_technique],
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  form partial: 'form'

  index do
    column :libelle
    column :categorie
    column :intitule do |question|
      question.transcription_ecrite_pour(:intitule)
    end
    column :metacompetence
    column :type_qcm
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end

  controller do
    def update
      if @question.update(question_params)
        @question.supprime_attachment_sur_requete
        redirect_to admin_question_qcm_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def question_params
      params.require(:question_qcm).permit(
        :categorie, :libelle, :nom_technique, :description,
        :metacompetence, :type_qcm, :illustration, :supprimer_illustration,
        :supprimer_audio_intitule,
        :supprimer_audio_modalite_reponse,
        choix_attributes: %i[id intitule audio type_choix _destroy nom_technique],
        transcriptions_attributes: %i[id categorie ecrit audio _destroy]
      )
    end

    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end
  end
end
