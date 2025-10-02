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
      locals: { comparaison: comparaison, beneficiaire: beneficiaire, structure: structure }
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
    helper_method :comparaison, :structure

    def evaluations
      @evaluations ||= Evaluation.where(id: params[:evaluation_ids])
                            .includes(campagne: { situations_configurations: :situation })
    end

    def comparaison
      @comparaison ||= begin
        ComparaisonEvaluations.new(evaluations)
      end
    end

    def structure
      compte_id = Campagne.joins(:evaluations)
                         .where(evaluations: evaluations)
                         .select(:compte_id)
      structure_id = Compte.where(id: compte_id)
                           .select(:structure_id)
      Structure.find structure_id
    end

    def disposition
      Rails.env.development? ? "inline" : "attachment"
    end
  end
end
