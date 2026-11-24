ActiveAdmin.register QuestionSousConsigne do
  liste_dsfr

  permit_params :libelle, :nom_technique, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  action_item :importer_question, only: :index do
    link_to "Importer questions sous consigne",
            admin_import_xls_path(type: QuestionSousConsigne::QUESTION_TYPE, model: "question",
                                  redirect_to: admin_question_sous_consignes_path)
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
