ActiveAdmin.register_page "Comparaison" do
  belongs_to :beneficiaire

  content title: "Comparer les évaluations" do
    if !comparaison.valid?
      flash[:error] = I18n.t("admin.comparaison.errors.limite_evaluations")
      redirect_to admin_beneficiaire_path(beneficiaire)
    end

    render partial: "show", locals: { comparaison: comparaison }
  end

  page_action :download_pdf, method: :get do
    beneficiaire = Beneficiaire.find params[:beneficiaire_id]
    html_content = render_to_string(
      template: "admin/comparaison/pdf",
      layout: "application",
      locals: { comparaison: comparaison, beneficiaire: beneficiaire }
    )

    pdf_path = Html2Pdf.genere_pdf_depuis_html(html_content)
    if pdf_path == false
      flash[:error] = t(".erreur_generation_pdf")
      redirect_to admin_beneficiaire_comparaison_path(evaluation_ids: params[:evaluation_ids])
    else
      send_file(pdf_path, filename: "#{beneficiaire.nom.parameterize}.pdf", type: "application/pdf",
                          disposition: disposition)
    end
  end

  controller do
    helper_method :comparaison

    def comparaison
      @comparaison ||= begin
        evaluations = Evaluation.where(id: params[:evaluation_ids])
                              .includes(campagne: { situations_configurations: :situation })
        ComparaisonEvaluations.new(evaluations)
      end
    end

    def disposition
      Rails.env.development? ? "inline" : "attachment"
    end
  end
end
