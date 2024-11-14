# frozen_string_literal: true

ActiveAdmin.register QuestionSousConsigne do
  menu parent: 'Parcours', if: proc { current_compte.superadmin? }

  permit_params :libelle, :nom_technique, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  action_item :importer_question, only: :index do
    link_to 'Importer questions sous consigne', admin_import_xls_path(type: 'QuestionSousConsigne')
  end

  action_item :exporter_question, only: :show do
    link_to 'Exporter la question en XLS', admin_question_export_xls_path(question_id: params[:id])
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
      render partial: 'admin/questions/input_illustration', locals: { f: f }
    end
    f.object.transcriptions.build(categorie: :intitule) if f.object.transcription_intitule.nil?

    f.has_many :transcriptions, allow_destroy: false, new_record: false,
                                heading: false do |t|
      t.input :id, as: :hidden
      t.input :ecrit, label: t('.label.intitule'), input_html: { rows: 4 }
      t.input :audio, as: :file, label: t('.label.intitule_audio'),
                      input_html: { accept: Transcription::AUDIOS_CONTENT_TYPES.join(',') }
      t.input :categorie, as: :hidden, input_html: { value: :intitule }
    end

    f.inputs do
      if f.object.transcription_intitule&.audio&.attached?
        f.input :supprimer_audio_intitule, as: :boolean,
                                           hint: tag_audio(f.object.transcription_intitule)
      end
    end

    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle do |q|
      link_to q.libelle, admin_question_sous_consigne_path(q)
    end
    column :intitule do |question|
      question.transcription_intitule&.ecrit
    end
    column :created_at
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end

  show do
    render partial: 'show'
  end
end
