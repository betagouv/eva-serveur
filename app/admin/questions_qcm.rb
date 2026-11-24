ActiveAdmin.register QuestionQcm do
  liste_dsfr

  before_action :set_question, only: %i[update]

  permit_params :categorie, :libelle, :nom_technique, :description,
                :type_qcm, :passable, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :demarrage_audio_modalite_reponse,
                :supprimer_audio_modalite_reponse, :supprimer_audio_consigne,
                choix_attributes: %i[id intitule audio type_choix score _destroy nom_technique],
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
    bouton_export_question_xls(resource)
  end

  index download_links: %i[xls]

  show do
    render partial: "show"
  end

  controller do
    include ExportQuestionsXls

    def find_resource
      collection = scoped_collection
      collection = collection.includes(choix: :audio_attachment) if action_name == "show"
      collection.where(id: params[:id]).first!
    end

    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end
  end
end
