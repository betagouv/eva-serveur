ActiveAdmin.register StructureLocale do
  actions :all

  config.sort_order = "created_at_desc"

  permit_params do
    params = [ :nom, :type_structure, :code_postal, :parent_id, :siret,
               :autorisation_creation_campagne, :usage, :email_contact, :telephone ]
    params << :opco_id if current_compte.au_moins_admin?
    params
  end

  # Les filtres sont rendus par FiltresComponent dans l'en-tête de la page ; ransack
  # les applique toujours à partir de params[:q]
  config.filters = false
  config.current_filters = false

  index download_links: %i[xls json]

  xls do
    whitelist
    column :nom
    column :code_postal
    column :region
    column :type_structure do |structure|
      traduction_type_structure(structure.type_structure)
    end
    column :usage do |structure|
      traduction_usage(structure.usage)
    end
    column :nombre_evaluations
    column :date_derniere_evaluation
    column "Date de création", &:created_at
  end

  show do
    render partial: "admin/structures/show", locals: { structure: resource }
  end

  member_action :envoyer_invitation, method: :post do
    envoyer_invitation_et_rediriger
  end

  form partial: "form"

  controller do
    before_action :trouve_campagnes, only: :show
    before_action :entete_index, only: :index

    helper_method :statistiques, :nombres_activation

    def trouve_campagnes
      @campagnes = Campagne.de_la_structure(resource)
    end

    def scoped_collection
      end_of_association_chain.avec_nombre_evaluations_et_date_derniere_evaluation
    end

    def create
      @structure_locale = StructureLocale.new(permitted_params[:structure_locale])
      @structure_locale.current_ability = current_ability

      if sauvegarde_et_cree_campagne
        if current_compte.structure.blank?
          rejoint_structure_et_redirige
        else
          redirect_to admin_structure_locale_path(@structure_locale)
        end
      else
        render :new
      end
    end

    def update
      @structure_locale = resource
      @structure_locale.current_ability = current_ability

      if @structure_locale.update(permitted_params[:structure_locale])
        AffiliationOpcoService.new(@structure_locale).affilie_opcos
        redirect_to admin_structure_locale_path(@structure_locale), **flash_apres_mise_a_jour
      else
        render :edit
      end
    end

    def entete_index
      @page_title = active_admin_config.plural_resource_label
      @page_dsfr = true
      @entete_dsfr = true
      @filtres = Structures::FiltresListe.new(params[:q], current_compte,
                                              activation: statistiques.statut)
    end

    def statistiques
      @statistiques ||= Structures::StatistiquesActivation.new(
        Structures::Activation, actif: params[:stats].present?, statut: params[:activation]
      )
    end

    # Étape de la chaîne d'ActiveAdmin qui appliquait ses scopes
    def apply_scoping(structures)
      statistiques.applique(structures)
    end

    # Les filtres sont rendus avant le tableau : la liste doit être calculée pour compter
    def nombres_activation
      collection
      statistiques.nombres
    end
    private :entete_index, :statistiques, :nombres_activation
    protected :apply_scoping

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
      fallback = admin_structure_locale_path(resource)
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

    def flash_apres_mise_a_jour
      if @structure_locale.verification_siret_indisponible
        { alert: I18n.t("admin.structures_locales.mise_a_jour.siret_non_verifie") }
      else
        { notice: I18n.t("admin.structures_locales.mise_a_jour.succes") }
      end
    end

    def sauvegarde_et_cree_campagne
      ActiveRecord::Base.transaction do
        resultat = @structure_locale.save
        if resultat
          AffiliationOpcoService.new(@structure_locale).affilie_opcos
          CampagneCreateur.new(@structure_locale, current_compte).cree_campagne_opco!
        end
        resultat
      end
    end

    def rejoint_structure_et_redirige
      current_compte.rejoindre_structure(@structure_locale)
      redirect_to admin_dashboard_path, notice: I18n.t("nouvelle_structure.bienvenue")
    end
  end
end
