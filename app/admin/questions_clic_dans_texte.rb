ActiveAdmin.register QuestionClicDansTexte do
  menu parent: "Parcours", if: proc { can? :manage, Compte }

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
    link_to "Exporter la question en XLS", admin_question_export_xls_path(question_id: params[:id])
  end

  form partial: "form"

  index do
    column :libelle do |q|
      link_to q.libelle, admin_question_clic_dans_texte_path(q)
    end
    column :categorie
    column :intitule do |question|
      question.transcription_intitule&.ecrit
    end
    column :created_at
    actions
  end

  show do
    render partial: "show"
  end
end
