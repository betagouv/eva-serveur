# frozen_string_literal: true

ActiveAdmin.register_page "import_xls" do
  menu false

  content title: proc { I18n.t("active_admin.import_xls.title.#{params[:model]}") } do
    render partial: "admin/import_xls/form",
           locals: {
             model: params[:model],
             type: params[:type],
             redirect_to: params[:redirect_to]
           }
  end

  page_action :create, method: :post do
    return invalide_format_xls unless ImportExport::ImportXls.fichier_xls?(file)

    if file
      importe_fichier!

      flash[:success] = I18n.t("active_admin.import_xls.flash.succes")
    else
      flash[:error] = I18n.t("active_admin.import_xls.flash.echec")
    end
    redirect_to lien_redirection
  rescue ImportExport::ImportXls::Error => e
    redirect_apres_erreur(e.message)
  end

  controller do
    def importe_fichier!
      if model == "questionnaire"
        import_questionnaire
      elsif model == "question"
        import_questions
      end
    end

    def import_questions
      ImportExport::Questions::ImportExportDonnees.new(type: type)
                                                  .importe_donnees(file)
    end

    def import_questionnaire
      ImportExport::Questionnaire::Import.new(
        ImportExport::Questionnaire::ImportExportDonnees::HEADERS_ATTENDUS
      ).import_from_xls(file)
    end

    def type
      params[:type]
    end

    def model
      params[:model]
    end

    def file
      params[:file_xls]
    end

    def lien_redirection
      params[:redirect_to].presence || admin_import_xls_path(type: type, model: model)
    end

    def invalide_format_xls
      redirect_apres_erreur(I18n.t("active_admin.import_xls.flash.format_invalide", format: "XLS"))
    end

    def redirect_apres_erreur(message)
      flash[:error] = message
      redirect_to admin_import_xls_path(type: type, model: model, redirect_to: params[:redirect_to])
    end
  end
end
