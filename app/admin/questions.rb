# frozen_string_literal: true

ActiveAdmin.register Question do
  menu false

  member_action :export_xls, method: :get do
    question = Question.find(params[:id])
    export =
      ImportExport::Questions::ImportExportDonnees.new(questions: [question], type: question.type)
                                                  .exporte_donnees
    send_data export[:xls],
              content_type: export[:content_type],
              filename: export[:filename]
  end

  controller do
    def import_xls
      return if fichier_import.blank?
      return invalide_format_xls unless ImportExport::ImportXls.fichier_xls?(fichier_import)

      initialise_import
      flash[:success] = I18n.t('.layouts.succes.import_question')
      redirect_to redirection_apres_import
    rescue ImportExport::Questions::Import::Error => e
      erreur_import(e)
    rescue ImportExport::ImportXls::Error => e
      raise ImportExport::Questions::ImportExportDonnees::Error, e.message
    end

    private

    def fichier_import
      params[:question][:file_xls]
    end

    def type_question
      params[:question][:type]
    end

    def initialise_import
      ImportExport::Questions::ImportExportDonnees.new(type: type_question)
                                                  .importe_donnees(fichier_import)
    end

    def erreur_import(error)
      flash[:error] = error.message
      redirect_to admin_import_xls_path(type: type_question)
    end

    private

    def redirection_apres_import
      redirection_paths = {
        QuestionClicDansImage::QUESTION_TYPE => admin_questions_clic_dans_image_path,
        QuestionGlisserDeposer::QUESTION_TYPE => admin_questions_glisser_deposer_path,
        QuestionQcm::QUESTION_TYPE => admin_question_qcms_path,
        QuestionSaisie::QUESTION_TYPE => admin_questions_saisies_path,
        QuestionSousConsigne::QUESTION_TYPE => admin_question_sous_consignes_path,
        QuestionClicDansTexte::QUESTION_TYPE => admin_questions_clic_dans_texte_path
      }

      redirection_paths[type_question] || admin_questions_path
    end

    def invalide_format_xls
      flash[:error] = I18n.t('.layouts.erreurs.import_question.format_invalide', format: 'XLS')
      redirect_to admin_import_xls_path(type: type_question)
    end
  end
end
