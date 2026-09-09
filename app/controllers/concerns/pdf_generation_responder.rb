module PdfGenerationResponder
  extend ActiveSupport::Concern

  def demarre_generation_pdf(html_content, nom)
    token = Pdf::GenerationToken.genere(current_compte.id)
    Pdf::GenerationJob.perform_later(token, html_content, nom)
    if request.xhr?
      render json: { token: token }
    else
      redirect_to admin_pdf_generation_path(token)
    end
  end
end
