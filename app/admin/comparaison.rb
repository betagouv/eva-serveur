ActiveAdmin.register_page "Comparaison" do
  belongs_to :beneficiaire

  content title: "Comparer les évaluations" do
    evaluations = Evaluation.where(id: params[:evaluation_ids])
                            .includes(campagne: { situations_configurations: :situation })
    comparaison = ComparaisonEvaluations.new(evaluations)
    if !comparaison.valid?
      flash[:error] = I18n.t("admin.comparaison.errors.limite_evaluations")
      redirect_to admin_beneficiaire_path(beneficiaire)
    end

    render partial: "comparaison", locals: { comparaison: comparaison }
  end
end
