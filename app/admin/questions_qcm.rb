# frozen_string_literal: true

ActiveAdmin.register QuestionQcm do
  before_action :set_question, only: %i[update]

  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :categorie, :libelle, :nom_technique, :description,
                :metacompetence, :type_qcm, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :supprimer_audio_modalite_reponse, :supprimer_audio_consigne,
                choix_attributes: %i[id intitule audio type_choix _destroy nom_technique],
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  form partial: 'form'

  action_item :importer_question, only: :index, if: -> { can? :manage, Question } do
    link_to 'Importer question qcm',
            admin_import_xls_path(type: 'QuestionQcm')
  end

  index do
    column :libelle do |q|
      link_to q.libelle, admin_question_qcm_path(q)
    end
    column :categorie
    column :intitule do |question|
      question.transcription_intitule&.ecrit
    end
    column :metacompetence
    column :type_qcm
    column :created_at
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end

  show do
    render partial: 'show'
  end

  controller do
    def update
      if @question.update(question_params)
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
        :supprimer_audio_consigne,
        choix_attributes: %i[id intitule audio type_choix _destroy nom_technique],
        transcriptions_attributes: %i[id categorie ecrit audio _destroy]
      )
    end

    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end
  end
end
