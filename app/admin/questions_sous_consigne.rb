# frozen_string_literal: true

ActiveAdmin.register QuestionSousConsigne do
  menu parent: 'Parcours', if: proc { current_compte.superadmin? }

  permit_params :libelle, :nom_technique,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
      f.object.transcriptions.build(categorie: :intitule) if f.object.transcription_intitule.nil?

      f.has_many :transcriptions, allow_destroy: false, new_record: false, heading: false do |t|
        t.input :ecrit, label: t('.label.intitule')
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
