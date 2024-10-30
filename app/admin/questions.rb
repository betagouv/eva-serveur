# frozen_string_literal: true

ActiveAdmin.register Question do
  menu false

  controller do
    def import_xls
      return if params[:file_xls].blank?

      import = ImportQuestion.new(params[:type])
      @question = import.remplis_donnees(params[:file_xls])
      ## TODO gère l'erreur si la question n'a pas pu être créée
      redirect_to redirection_apres_import
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
