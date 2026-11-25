ActiveAdmin.register QuestionClicDansImage do
  liste_dsfr { |parametres| Referentiels::FiltresListe.new(parametres) }

  before_action :set_question, only: %i[update]

  permit_params :libelle, :nom_technique, :description, :passable,
                :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :image_au_clic,
                :demarrage_audio_modalite_reponse,
                :zone_cliquable, :supprimer_zone_cliquable,
                :supprimer_audio_modalite_reponse, :supprimer_audio_consigne,
                :supprimer_image_au_clic,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  form partial: "form"

  index download_links: %i[xls]

  action_item :exporter_question, only: :show do
    bouton_export_question_xls(resource)
  end

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
