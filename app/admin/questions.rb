# frozen_string_literal: true

ActiveAdmin.register Question do
  menu false

  controller do
    def import_xls
      return if params[:file_xls].blank?

      importe_question
      flash[:success] = I18n.t('.layouts.succes.import_question')
      redirect_to redirection_apres_import
    rescue ImportQuestion::Error => e
      erreur_import(e)
    rescue ImportXls::Error => e
      raise ImportQuestion::Error, e.message
    end

    private

    def importe_question
      import = ImportQuestion.new(Question.new(type: params[:type]))
      @question = import.remplis_donnees(params[:file_xls])
    end

    def erreur_import(error)
      flash[:error] = error.message
      redirect_to admin_import_xls_path(type: params[:type])
    end

    private

    def redirection_apres_import
      redirection_paths = {
        'QuestionClicDansImage' => edit_admin_question_clic_dans_image_path(@question),
        'QuestionGlisserDeposer' => edit_admin_question_glisser_deposer_path(@question),
        'QuestionQcm' => edit_admin_question_qcm_path(@question),
        'QuestionSaisie' => edit_admin_question_saisie_path(@question),
        'QuestionSousConsigne' => edit_admin_question_sous_consigne_path(@question)
      }

      redirection_paths[params[:type]]
    end
  end
end
