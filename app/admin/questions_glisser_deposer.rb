ActiveAdmin.register QuestionGlisserDeposer do
  liste_dsfr

  before_action :set_question, only: %i[update]

  permit_params :libelle, :nom_technique, :description, :passable, :illustration,
                :supprimer_illustration, :supprimer_audio_modalite_reponse,
                :supprimer_audio_intitule, :supprimer_zone_depot, :zone_depot,
                :supprimer_audio_consigne, :demarrage_audio_modalite_reponse, :orientation,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy],
                reponses_attributes: %i[id illustration intitule position type_choix position_client
                                        nom_technique _destroy]

  filter :libelle
  filter :nom_technique

  form partial: "form"

  action_item :importer_question, only: :index do
    link_to "Importer questions glisser déposer",
            admin_import_xls_path(type: QuestionGlisserDeposer::QUESTION_TYPE, model: "question",
                                  redirect_to: admin_questions_glisser_deposer_path)
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

    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end
  end
end
