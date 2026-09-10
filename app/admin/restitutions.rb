ActiveAdmin.register Partie, as: "Restitutions" do
  actions :show, :destroy

  controller do
    helper_method :chemin_vue

    def find_resource
      partie = Partie.find params[:id]
      FabriqueRestitution.instancie partie
    end

    def chemin_vue
      resource.class.to_s.underscore.tr("/", "_")
    end

    def destroy
      evaluation = resource.evaluation
      resource.supprimer
      chemin_evaluation = if evaluation.is_a?(EvaluationEvapro)
        admin_evaluation_evapro_path(evaluation)
      else
        admin_evaluation_eva_path(evaluation)
      end
      redirect_to chemin_evaluation
    end
  end

  member_action :recalcule, method: :post do
    restitution = resource
    restitution.persiste
    PersisteRestitutionJob.perform_now(restitution.evaluation)
    redirect_to admin_restitution_path(restitution),
      notice: I18n.t("admin.restitutions.recalcule.notice")
  end

  action_item :recalcule, only: :show do
    link_to I18n.t("admin.restitutions.recalcule.bouton"),
           recalcule_admin_restitution_path(resource),
           method: :post
  end

  show do
    begin
      render chemin_vue, restitution: resource
    rescue ActionView::MissingTemplate
      nil
    end
    render "restitution_metriques",
           metriques_partie: resource.partie.metriques,
           moyenne: resource.moyennes_metriques,
           ecart_type: resource.ecarts_types_metriques,
           cote_z: resource.cote_z_metriques
    render "restitution_competences_de_base", restitution: resource
    render "restitution_competences", restitution: resource
  end

  sidebar :informations_generales, only: :show
end
