# frozen_string_literal: true

ActiveAdmin.register QuestionQcm do
  before_action :set_question, only: %i[update]

  menu parent: "Parcours", if: proc { can? :manage, Compte }

  permit_params :categorie, :libelle, :nom_technique, :description,
                :type_qcm, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :demarrage_audio_modalite_reponse,
                :supprimer_audio_modalite_reponse, :supprimer_audio_consigne,
                choix_attributes: %i[id intitule audio type_choix _destroy nom_technique],
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  form partial: "form"

  action_item :importer_question, only: :index do
    link_to "Importer questions QCM",
            admin_import_xls_path(type: QuestionQcm::QUESTION_TYPE, model: "question",
                                  redirect_to: admin_question_qcms_path)
  end

  action_item :exporter_question, only: :show do
    link_to "Exporter la question en XLS", admin_question_export_xls_path(question_id: params[:id])
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
    column "", class: "bouton-action" do
      render partial: "components/bouton_menu_actions"
    end
  end

  show do
    render partial: "show"
  end

  controller do
    def find_resource
      scoped_collection.includes(choix: :audio_attachment).where(id: params[:id]).first!
    end

    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end
  end
end
