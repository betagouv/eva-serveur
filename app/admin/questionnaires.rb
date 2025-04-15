# frozen_string_literal: true

require 'zip'

ActiveAdmin.register Questionnaire do
  menu parent: 'Parcours', if: proc { can? :manage, Compte }

  permit_params :libelle, :nom_technique,
                questionnaires_questions_attributes: %i[id question_id _destroy]

  filter :questions

  member_action :export_questions, method: :get

  action_item :export_questionnaire, only: :show do
    link_to 'Exporter le questionnaire', export_admin_questionnaire_path(resource)
  end

  action_item :export_questions, only: :show do
    link_to 'Exporter le contenu des questions',
            export_questions_admin_questionnaire_path(resource),
            format: :xls
  end

  action_item :import_xls, only: :index do
    link_to 'Importer un questionnaire en XLS',
            admin_import_xls_path(model: 'questionnaire', redirect_to: admin_questionnaires_path)
  end

  member_action :export, method: :get do
    questionnaire = Questionnaire.find(params[:id])
    export =
      ImportExport::Questionnaire::ImportExportDonnees.new(questionnaires: [questionnaire])
                                                      .exporte_donnees
    send_data export[:xls],
              content_type: export[:content_type],
              filename: export[:filename]
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :nom_technique
      f.has_many :questionnaires_questions, allow_destroy: true do |c|
        c.input :id, as: :hidden
        c.input :question
      end
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle do |q|
      link_to q.libelle, admin_questionnaire_path(q)
    end
    column :nom_technique
    column :created_at
    actions do |questionnaire|
      link_to 'Exporter', export_admin_questionnaire_path(questionnaire)
    end
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end

  show do
    render partial: 'show'
  end

  controller do
    def find_resource
      scoped_collection.where(id: params[:id]).includes(questionnaires_questions: :question).first!
    end

    def export_questions
      questionnaire = find_resource
      compressed_filestream = generate_zip_file(questionnaire.questions_par_type)

      send_data compressed_filestream.read,
                filename: questionnaire.nom_fichier_export,
                type: 'application/zip'
    end

    private

    def generate_zip_file(questions_par_type)
      Zip::OutputStream.write_buffer do |zip|
        questions_par_type.each do |type, questions|
          export =
            ImportExport::Questions::ImportExportDonnees.new(questions: questions,
                                                             type: type).exporte_donnees
          zip.put_next_entry(export[:filename])
          zip.write export[:xls]
        end
      end.tap(&:rewind)
    end
  end
end
