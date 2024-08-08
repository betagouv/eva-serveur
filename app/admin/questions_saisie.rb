# frozen_string_literal: true

ActiveAdmin.register QuestionSaisie do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :categorie, :libelle, :nom_technique, :message,
                :suffix_reponse, :description, :reponse_placeholder,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :categorie, as: :select
      f.input :nom_technique
      f.input :description

      if f.object.transcription_pour(:intitule).nil?
        f.object.transcriptions.build(categorie: :intitule)
      end

      f.has_many :transcriptions, allow_destroy: false, new_record: false, heading: false do |t|
        t.input :ecrit, label: t('.label.intitule')
      end
      f.input :suffix_reponse
      f.input :reponse_placeholder
      f.input :type_saisie
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle
    column :categorie
    column :intitule do |question|
      question.transcription_ecrite_pour(:intitule)
    end
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
