# frozen_string_literal: true

ActiveAdmin.register QuestionSousConsigne do
  menu parent: 'Parcours', if: proc { current_compte.superadmin? }

  permit_params :libelle, :nom_technique, :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
      render partial: 'admin/questions/input_illustration', locals: { f: f }

      f.object.transcriptions.build(categorie: :intitule) if f.object.transcription_intitule.nil?

      render partial: 'admin/transcriptions/input_ecrit_audio',
             locals: { f: f, transcription_categorie: :intitule }

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
    column :libelle
    column :intitule do |question|
      question.transcription_intitule&.ecrit
    end
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
