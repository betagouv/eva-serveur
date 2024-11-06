# frozen_string_literal: true

ActiveAdmin.register QuestionGlisserDeposer do
  before_action :set_question, only: %i[update]

  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique, :description, :illustration, :supprimer_illustration,
                :supprimer_audio_modalite_reponse, :supprimer_audio_intitule,
                :supprimer_zone_depot, :zone_depot, :supprimer_audio_consigne,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy],
                reponses_attributes: %i[id illustration position type_choix position_client
                                        nom_technique _destroy]

  filter :libelle
  filter :nom_technique

  form partial: 'form'

  action_item :importer_question, only: :index do
    link_to 'Importer question glisser déposer',
            admin_import_xls_path(type: 'QuestionGlisserDeposer')
  end

  action_item :exporter_question, only: :show do
    link_to 'Exporter le contenu de la question',
            admin_question_export_xls_path(question_id: params[:id])
  end

  index do
    column :libelle do |q|
      link_to q.libelle, admin_question_glisser_deposer_path(q)
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

  controller do
    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end
  end
end
