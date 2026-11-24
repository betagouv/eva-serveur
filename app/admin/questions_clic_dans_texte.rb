ActiveAdmin.register QuestionClicDansTexte do
  liste_dsfr { |parametres| Referentiels::FiltresListe.new(parametres) }

  permit_params :categorie, :libelle, :nom_technique, :message,
                :suffix_reponse, :description, :passable, :reponse_placeholder,
                :illustration, :supprimer_illustration, :texte_sur_illustration,
                :supprimer_audio_intitule,
                :demarrage_audio_modalite_reponse,
                :supprimer_audio_modalite_reponse,
                :supprimer_audio_consigne,
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
