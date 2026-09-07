module Admin
  class PdfGenerationsController < ApplicationController
    before_action :authenticate_compte!

    def show
      @token = params[:id]
      redirect_to admin_dashboard_path, alert: t("admin.erreur_generation_pdf") unless jeton_valide?
    end

    private

    def jeton_valide?
      Pdf::GenerationToken.compte_id(@token) == current_compte.id
    end
  end
end
