ActiveAdmin.register QuestionSousConsigne do
  liste_dsfr { |parametres| Referentiels::FiltresListe.new(parametres) }

  permit_params :libelle, :nom_technique, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

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
