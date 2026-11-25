ActiveAdmin.register StructureOpco do
  config.sort_order = "created_at_desc"

  permit_params :nom, :siret, :opco_id

  # Les filtres sont rendus par FiltresComponent dans l'en-tête de la page ; ransack
  # les applique toujours à partir de params[:q]
  config.filters = false
  config.current_filters = false

  show do
    render partial: "admin/structures/show", locals: { structure: resource }
  end

  member_action :envoyer_invitation, method: :post do
    envoyer_invitation_et_rediriger
  end

  form partial: "form"

  controller do
    before_action :entete_index, only: :index

    def entete_index
      @page_title = active_admin_config.plural_resource_label
      @page_dsfr = true
      @filtres = Structures::FiltresListe.new(params[:q], current_compte, activation: nil)
    end
    private :entete_index

    def create
      @structure_opco = StructureOpco.new(
          permitted_params[:structure_opco]
        )
      @structure_opco.current_ability = current_ability

      if @structure_opco.save
        redirect_to admin_structure_opco_path(@structure_opco)
      else
        render :new
      end
    end

    def update
      @structure_opco = resource
      @structure_opco.current_ability = current_ability

      if @structure_opco.update(permitted_params[:structure_opco])
        redirect_to admin_structure_opco_path(@structure_opco)
      else
        render :edit
      end
    end

    private

    def envoyer_invitation_et_rediriger
      result = EnvoiInvitationService.new(
        structure: resource,
        invitant: current_compte,
        email: invitation_params[:email],
        message: invitation_params[:message],
        role: invitation_params[:role].presence
      ).call

      redirect_apres_envoi_invitation(result)
    end

    def redirect_apres_envoi_invitation(result)
      fallback = admin_structure_opco_path(resource)
      if result.success?
        notice = I18n.t("admin.structures.membres.invitation_envoyee", email: result.email)
        redirect_back fallback_location: fallback, notice: notice
      else
        alert = I18n.t("admin.structures.membres.#{result.error}")
        redirect_back fallback_location: fallback, alert: alert
      end
    end

    def invitation_params
      params.fetch(:invitation, ActionController::Parameters.new).permit(:email, :message, :role)
    end

    def compte_autorise_pour_invitation?
      EnvoiInvitationService.autorise_invitation?(structure: resource, invitant: current_compte)
    end
  end
end
