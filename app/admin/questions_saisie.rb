ActiveAdmin.register QuestionSaisie do
  liste_dsfr

  permit_params :categorie, :libelle, :nom_technique, :message,
                :suffix_reponse, :description, :reponse_placeholder, :type_saisie, :passable, :aide,
                :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :demarrage_audio_modalite_reponse,
                :supprimer_audio_modalite_reponse,
                :supprimer_audio_consigne,
                :texte_a_trous,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy],
                reponses_attributes: %i[id intitule audio type_choix _destroy nom_technique]

  filter :libelle
  filter :nom_technique

  action_item :importer_question, only: :index do
    link_to "Importer questions saisies",
            admin_import_xls_path(type: QuestionSaisie::QUESTION_TYPE, model: "question",
                                  redirect_to: admin_questions_saisies_path)
  end

  action_item :exporter_question, only: :show do
    bouton_export_question_xls(resource)
  end

  controller do
    include ExportQuestionsXls
  end

  form partial: "form"

  index download_links: %i[xls]

  show do
    render partial: "show"
  end
end
