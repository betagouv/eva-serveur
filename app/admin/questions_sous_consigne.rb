# frozen_string_literal: true

ActiveAdmin.register QuestionSousConsigne do
  menu parent: "Parcours", if: proc { current_compte.superadmin? }

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
    link_to "Exporter la question en XLS", admin_question_export_xls_path(question_id: params[:id])
  end

  form partial: "form"

  index do
    column :libelle do |q|
      link_to q.libelle, admin_question_sous_consigne_path(q)
    end
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
