# frozen_string_literal: true

ActiveAdmin.register QuestionClicDansImage do
  before_action :set_question, only: %i[update]

  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique, :description,
                :illustration, :supprimer_illustration,
                :supprimer_audio_intitule,
                :image_au_clic,
                :zone_cliquable, :supprimer_zone_cliquable,
                :supprimer_audio_modalite_reponse, :supprimer_audio_consigne,
                :supprimer_image_au_clic,
                transcriptions_attributes: %i[id categorie ecrit audio _destroy]

  filter :libelle
  filter :nom_technique

  form partial: 'form'

  index do
    column :libelle do |q|
      link_to q.libelle, admin_question_clic_dans_image_path(q)
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

  action_item :importer_question, only: :index, if: -> { can? :manage, Question } do
    link_to 'Importer question clic dans image',
            admin_import_xls_path(url: import_xls_admin_questions_clic_dans_image_path)
  end

  show do
    render partial: 'show'
  end

  controller do
    def set_question
      @question = Question.includes(transcriptions: :audio_attachment).find(params[:id])
    end

    def import_xls
      return if params[:csv_file].blank?

      import = ImportQuestion.new('QuestionClicDansImage')

      question = import.preremplis_donnees(params[:csv_file])
      redirect_to edit_admin_question_clic_dans_image_path(question)
    end
  end
end
