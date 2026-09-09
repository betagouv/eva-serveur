ActiveAdmin.register_page "Comparaison" do
  menu false

  content title: "Comparer les évaluations" do
    if !comparaison.valid?
      flash[:error] = I18n.t("admin.comparaison.errors.limite_evaluations")
      redirect_to admin_beneficiaire_path(beneficiaire)
    end

    render partial: "show", locals: { comparaison: comparaison, beneficiaire: beneficiaire }
  end

  page_action :download_pdf, method: :get do
    beneficiaire = Beneficiaire.find params[:beneficiaire_id]
    html_content = String.new(render_to_string(
      template: "admin/comparaison/pdf",
      layout: "application",
      locals: { comparaison: comparaison, beneficiaire: beneficiaire, structure: structure }
    ))

    demarre_generation_pdf(html_content, "#{beneficiaire.nom.parameterize}.pdf")
  end

  controller do
    include PdfGenerationResponder

    helper_method :comparaison, :structure, :beneficiaire

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

    def beneficiaire
      @beneficiaire ||= begin
        if params[:beneficiaire_id].present?
          Beneficiaire.find params[:beneficiaire_id]
        elsif evaluations.any? && (first_evaluation = evaluations.first)
          first_evaluation.beneficiaire
        end
      end
    end
  end
end
