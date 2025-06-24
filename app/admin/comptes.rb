# frozen_string_literal: true

ActiveAdmin.register Compte do
  menu if: proc { current_compte.structure_id.present? && can?(:read, Compte) }
  permit_params :email, :password, :password_confirmation, :role, :structure_id,
                :statut_validation, :prenom, :nom, :telephone, :mode_tutoriel,
                :cgu_acceptees

  includes :structure

  config.sort_order = "created_at_desc"

  filter :email
  filter :nom
  filter :prenom
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
         order_by: "nom_asc",
         if: proc { can? :manage, Compte }
  filter :role,
         as: :select,
         collection: Compte.roles.map { |v, id|
                       [ Compte.human_enum_name(:role, v), id ]
                     },
         if: proc { can? :manage, Compte }
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

  index do
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

  form do |f|
    f.inputs do
      f.input :prenom
      f.input :nom
      f.input :email
      f.input :telephone
      f.input :role, as: :select, collection: collection_roles if can?(:edit_role, f.object)
      if can? :manage, Compte
        f.input :structure
      else
        f.input :structure_id, as: :hidden, input_html: { value: current_compte.structure_id }
      end
      if current_compte.au_moins_admin? && compte != current_compte
        f.input :statut_validation, as: :radio
      end
      if peut_modifier_mot_de_passe?
        f.input :password, hint: resource.persisted? ? t(".aide_mot_de_passe") : ""
        f.input :password_confirmation
      end
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  csv do
    column :prenom
    column :nom
    column :email
    column :telephone
    column :statut_validation
    if can? :manage, Compte
      column :role
      column(:structure) { |c| c.structure.nom }
      column(:type_structure) { |c| c.structure.type_structure }
      column(:code_postal) { |c| c.structure.code_postal }
      column(:region) { |c| c.structure.region }
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
    helper_method :peut_modifier_mot_de_passe?, :collection_roles,
:collection_roles_pour_verification

    def update_resource(object, attributes)
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


    def collection_roles
      roles = current_compte.superadmin? ? Compte::ROLES : Compte::ROLES_STRUCTURE
      roles.map { |role| [ Compte.human_enum_name(:role, role), role ] }
    end

    def collection_roles_pour_verification
      current_compte.superadmin? ? Compte::ROLES : Compte::ROLES_POUR_VERIFICATION
    end

    def trouve_comptes
      comptes = Compte.de_la_structure(current_compte.structure).order(:prenom, :nom)
      @comptes_en_attente = comptes.validation_en_attente
      # @comptes_refuses = comptes.validation_refusee
      # @comptes_acceptes = comptes.validation_acceptee
    end
  end

  show do
    render "show"
  end
end
