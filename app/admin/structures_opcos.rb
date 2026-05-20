ActiveAdmin.register StructureOpco do
  # La position dans le menu est gérée par NavigationComponent

  permit_params :nom, :siret, :opco_id

  filter :nom, filters: [ :contains_unaccent, :eq ]
  filter :siret
  filter :created_at

  index dsfr_table: proc { true } do
    column :nom do |structure|
      link_to structure.nom, admin_structure_opco_path(structure)
    end
    column :siret do |structure|
      FormatageSiretHelper.formater_siret(structure.siret)
    end
    column :created_at do |structure|
      l(structure.created_at, format: :sans_heure)
    end
    actions
  end

  show do
    render partial: "admin/structures/show", locals: { structure: resource }
  end

  member_action :envoyer_invitation, method: :post do
    envoyer_invitation_et_rediriger
  end

  form partial: "form"

  controller do
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
