ActiveAdmin.register Compte do
  menu if: proc { current_compte.structure_id.present? && can?(:read, Compte) }
  permit_params :email, :password, :password_confirmation, :role, :structure_id,
                :statut_validation, :prenom, :nom, :telephone, :mode_tutoriel,
                :cgu_acceptees, :usage, :fonction, :service_departement

  includes :structure

  config.sort_order = "created_at_desc"

  filter :email
  filter :nom, filters: [ :contains_unaccent, :eq ]
  filter :prenom, filters: [ :contains_unaccent, :eq ]
  filter :statut_validation,
         as: :select,
         collection: Compte.statuts_validation.map { |v, id|
                       [ Compte.human_enum_name(:statut_validation, v), id ]
                     }

  filter :structure_id,
         as: :search_select_filter,
         url: proc { admin_structures_path },
         fields: %i[nom code_postal],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "lower_nom_asc",
         if: proc { current_compte.anlci? || current_compte.administratif? }
  filter :role,
         as: :select,
         collection: proc { collection_roles }
  filter :created_at

  filter :structure_type_structure_eq,
         as: :select,
         collection: ApplicationController.helpers.collection_types_structures,
         label: I18n.t("type_structure", count: 1, scope: "activerecord.attributes.structure"),
         if: proc { can? :manage, Compte }

  filter :structure_region_eq,
         as: :select,
         collection: proc { Structure.distinct.order(:region).pluck(:region) },
         label: I18n.t("region", scope: "activerecord.attributes.structure"),
         if: proc { can? :manage, Compte }

  def filtrer_par_activation_structure(statut_activation, options = {})
    options.merge!({ if: -> { params[:stats] && can?(:manage, Compte) } })
    scope statut_activation, options do |scope|
      scope.where(structure: Structure.send(statut_activation))
    end
  end

  scope :all, { default: true, if: -> { params[:stats] && can?(:manage, Compte) } }
  filtrer_par_activation_structure(:sans_campagne)
  filtrer_par_activation_structure(:pas_vraiment_utilisatrices)
  filtrer_par_activation_structure(:non_activees)
  filtrer_par_activation_structure(:actives)
  filtrer_par_activation_structure(:inactives)
  filtrer_par_activation_structure(:abandonnistes)

  index download_links: -> { %i[json xls] } do
    render "mise_en_avant_comptes_en_attente"
    render "index", context: self
  end

  action_item :stats, only: :index, if: -> { can? :manage, Compte } do
    if params[:stats]
      link_to t(".sans_stats"), admin_comptes_path
    else
      link_to t(".stats"), admin_comptes_path(stats: true)
    end
  end

  sidebar :aide_filtres,
          partial: "admin/structures_locales/aide_filtres_sidebar",
          only: :index,
          if: -> { params[:stats] && can?(:manage, Compte) }

  form partial: "form"

  xls(i18n_scope: %i[activerecord attributes compte], header_format: { weight: :bold }) do
    whitelist
    column(:structure) { |c| c.structure&.nom }
    column :nom
    column :prenom
    column :email
    column :telephone
    column(:role) { |c| Compte.human_enum_name(:role, c.role) }
    column(:statut_validation) do |c|
      Compte.human_enum_name(:statut_validation, c.statut_validation)
    end
    column :fonction
    column :service_departement
    column :created_at
    column :current_sign_in_at

    before_filter do |sheet|
      if @collection.count > ImportExport::ExportXls::NOMBRE_MAX_LIGNES
        sheet << [
          I18n.t("active_admin.export.limite_atteinte", limite: ImportExport::ExportXls::NOMBRE_MAX_LIGNES)
        ]
        @collection = @collection.limit!(ImportExport::ExportXls::NOMBRE_MAX_LIGNES)
      end
    end
  end

  member_action :rejoindre_structure, method: :patch do
    structure = Structure.find_by id: params[:structure_id]
    return redirect_to admin_recherche_structure_path unless structure

    resource.rejoindre_structure(structure)
    redirect_to admin_dashboard_path
  end

  member_action :accepter_cgu, method: :patch do
    resource.update!(cgu_acceptees: true)
    redirect_to admin_dashboard_path
  end

  member_action :autoriser, method: :patch do
    autoriser_compte
  end

  member_action :refuser, method: :patch do
    refuser_compte
  end

  member_action :verifier, method: :patch do
    params[:decision] == "Autoriser" ? autoriser_compte : refuser_compte
  end

  member_action :quitter_mode_tutoriel, method: :patch do
    current_compte.update(mode_tutoriel: false)
    redirect_to request.referer
  end

  controller do
    before_action :trouve_comptes, only: :index
    helper_method :peut_modifier_mot_de_passe?, :collection_roles, :roles_avec_description,
                  :structure_par_defaut, :champ_structure, :structures_filles,
                  :compte_a_des_campagnes?

    def destroy
      destroy! do |format|
        format.html { redirect_to redirection_apres_suppression }
      end
    end

    def redirection_apres_suppression
      if request.referer&.include?("?")
        request.referer
      else
        collection_path
      end
    end

    def update_resource(object, attributes)
      object.force_deplacement_structure = true if current_compte.superadmin?
      update_method = if attributes.first[:password].present?
                        :update
      else
                        :update_without_password
      end
      object.send(update_method, *attributes)
    end

    def peut_modifier_mot_de_passe?
      resource.new_record? ||
        resource == current_compte ||
        can?(:manage, Compte)
    end

    def autoriser_compte
      met_a_jour_role
      resource.validation_acceptee!
      redirect_to request.referer
    end

    def refuser_compte
      met_a_jour_role
      resource.validation_refusee!
      redirect_to request.referer
    end

    def met_a_jour_role
      resource.update(role: params[:role]) if params[:role].present?
    end

    def roles_avec_description
      collection_roles.map { |libelle, role| [ libelle, role, Compte::AIDES_ROLES[role] ] }
    end

    def collection_roles
      roles = current_compte.superadmin? ? Compte::ROLES : Compte::ROLES_STRUCTURE
      roles.map { |role| [ Compte.human_enum_name(:role, role), role ] }
    end

    def trouve_comptes
      comptes = Compte.de_la_structure(current_compte.structure).order(:prenom, :nom)
      @comptes_en_attente = comptes.validation_en_attente
    end

    def structure_par_defaut
      @structure_par_defaut ||= resource.structure || current_compte.structure
    end

    def structures_filles
      return [] unless current_compte.structure

      current_compte.structure.structures_locales_filles
    end

    def compte_a_des_campagnes?
      resource.persisted? && Campagne.exists?(compte_id: resource.id)
    end

    def champ_structure(form)
      return form.input :structure if can?(:manage, Compte)
      return champ_structure_lecture_seule(form) if resource.administratif?
      return champ_structure_structure_fille(form) if current_compte.administratif?

      champ_structure_hidden(form)
    end

    def champ_structure_structure_fille(form)
      if compte_a_des_campagnes?
        champ_structure_lecture_seule(form,
          hint: I18n.t("admin.comptes.form.structure_disabled_avec_campagnes"))
      else
        form.input :structure, collection: structures_filles, selected: structure_par_defaut&.id
      end
    end

    def champ_structure_lecture_seule(form, hint: nil)
      options = {
        collection: [ structure_par_defaut ],
        selected: structure_par_defaut&.id,
        input_html: { disabled: true }
      }
      options[:hint] = hint if hint
      form.input :structure, **options
      champ_structure_hidden(form)
    end

    def champ_structure_hidden(form)
      form.input :structure_id, as: :hidden, input_html: { value: structure_par_defaut&.id }
    end
  end

  show do
    render "show"
  end
end
