ActiveAdmin.register QuestionClicDansTexte do
  liste_dsfr

  permit_params :categorie, :libelle, :nom_technique, :message,
                :suffix_reponse, :description, :passable, :reponse_placeholder,
                :illustration, :supprimer_illustration, :texte_sur_illustration,
                :supprimer_audio_intitule,
                :demarrage_audio_modalite_reponse,
                :supprimer_audio_modalite_reponse,
                :supprimer_audio_consigne,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  action_item :importer_question, only: :index do
    link_to "Importer questions Clic dans texte",
            admin_import_xls_path(type: QuestionClicDansTexte::QUESTION_TYPE, model: "question",
                                  redirect_to: admin_questions_clic_dans_texte_path)
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
