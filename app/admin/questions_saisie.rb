# frozen_string_literal: true

ActiveAdmin.register QuestionSaisie do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :categorie, :libelle, :nom_technique, :message,
                :suffix_reponse, :description, :reponse_placeholder, :type_saisie,
                :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :supprimer_audio_modalite_reponse,
                :supprimer_audio_consigne,
                :texte_a_trous,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy],
                bonne_reponse_attributes: %i[id intitule audio type_choix _destroy nom_technique]

  filter :libelle
  filter :nom_technique

  action_item :importer_question, only: :index do
    link_to 'Importer questions saisies', admin_import_xls_path(type: QuestionSaisie::QUESTION_TYPE)
  end

  action_item :exporter_question, only: :show do
    link_to 'Exporter la question en XLS', admin_question_export_xls_path(question_id: params[:id])
  end

  form partial: 'form'

  index do
    column :libelle do |q|
      link_to q.libelle, admin_question_saisie_path(q)
    end
    column :categorie
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
