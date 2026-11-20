ActiveAdmin.register Compte do
  permit_params do
    attributs = %i[email prenom nom telephone mode_tutoriel cgu_acceptees usage fonction
                   service_departement]
    attributs += %i[password password_confirmation] if mot_de_passe_modifiable?
    attributs << :role if role_modifiable?
    attributs << :statut_validation if statut_validation_modifiable?
    attributs << :structure_id if structure_modifiable?
    attributs
  end

  before_create do |compte|
    if compte.structure.nil?
      compte.etape_inscription = "recherche_structure"
    else
      compte.etape_inscription = "complet"
    end
  end

  includes :structure

  config.sort_order = "created_at_desc"

  order_by(:prenom_nom) do |clause|
    table = clause.active_admin_config.resource_table_name
    "#{table}.prenom #{clause.order}, #{table}.nom #{clause.order}"
  end

  # Les filtres sont rendus par FiltresComponent dans l'en-tête de la page ; ransack
  # les applique toujours à partir de params[:q]
  config.filters = false
  config.current_filters = false

  index download_links: -> { %i[json xls] }

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
    before_action :trouve_comptes, :entete_index, only: :index

    helper_method :peut_modifier_mot_de_passe?, :collection_roles, :roles_avec_description,
                  :structure_par_defaut, :champ_structure, :structures_filles,
                  :compte_a_des_campagnes?, :statistiques?, :nombres_activation

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
      return unless can?(:edit_role, resource) && roles_attribuables.include?(params[:role])

      resource.update(role: params[:role])
    end

    def roles_avec_description
      collection_roles.map { |libelle, role| [ libelle, role, Compte::AIDES_ROLES[role] ] }
    end

    def collection_roles
      roles_attribuables.map { |role| [ Compte.human_enum_name(:role, role), role ] }
    end

    def roles_attribuables
      current_compte.superadmin? ? Compte::ROLES : Compte::ROLES_STRUCTURE
    end

    # Ne pas utiliser `resource` à la création : il se construit à partir des
    # paramètres autorisés, que ces méthodes servent justement à déterminer.
    def compte_en_edition
      resource if params[:id].present?
    end

    def mot_de_passe_modifiable?
      compte_en_edition.nil? || compte_en_edition == current_compte || can?(:manage, Compte)
    end

    def role_modifiable?
      cible = compte_en_edition || Compte.new(structure_id: structure_id_autorisee)
      can?(:edit_role, cible) && roles_attribuables.include?(params.dig(:compte, :role))
    end

    def statut_validation_modifiable?
      current_compte.au_moins_admin? && compte_en_edition != current_compte
    end

    def structure_modifiable?
      can?(:manage, Compte) || structure_id_autorisee.present?
    end

    def structure_id_autorisee
      structure_id = params.dig(:compte, :structure_id).presence
      structure_id if structures_attribuables_ids.include?(structure_id)
    end

    def structures_attribuables_ids
      ids = [ (compte_en_edition || current_compte).structure_id ]
      ids += structures_filles.map(&:id) if current_compte.administratif?
      ids.compact
    end

    def entete_index
      @page_title = active_admin_config.plural_resource_label
      @page_dsfr = true
      @filtres = Comptes::FiltresListe.new(params[:q], current_compte,
                                           gestion: can?(:manage, Compte),
                                           activation: (params[:activation] if statistiques?))
    end

    def statistiques?
      params[:stats].present? && can?(:manage, Compte)
    end

    # Étape de la chaîne d'ActiveAdmin qui appliquait ses scopes : en statistiques, la
    # liste se restreint au statut d'activation de la structure choisi
    def apply_scoping(comptes)
      @comptes_avant_activation = comptes
      return comptes unless statistiques?

      Comptes::ActivationStructure.filtre(comptes, params[:activation])
    end

    def nombres_activation
      collection
      Comptes::ActivationStructure.nombres(@comptes_avant_activation)
    end

    def trouve_comptes
      @comptes_en_attente = Compte.where(structure_id: current_compte.structure_id)
                                  .validation_en_attente
                                  .order(:prenom, :nom)
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

  action_item :voir_campagnes, only: :show, if: proc { can?(:read, Campagne) } do
    link_to I18n.t("admin.comptes.action_items.voir_campagnes",
                   count: Campagne.where(compte: resource).count),
            admin_campagnes_path(q: { compte_id_eq: resource.id })
  end

  show do
    render "show"
  end
end
