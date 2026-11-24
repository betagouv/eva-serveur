ActiveAdmin.register Campagne do
  permit_params :libelle, :code, :compte, :active, :privee,
                :compte_id, :affiche_competences_fortes, :parcours_type_id, :type_programme,
                options_personnalisation: [],
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  config.sort_order = "created_at_desc"

  includes :parcours_type

  # Les filtres sont rendus par FiltresComponent dans l'en-tête de la page ; ransack
  # les applique toujours à partir de params[:q]
  config.filters = false
  config.current_filters = false

  action_item :dupliquer, only: :show, if: proc { can?(:duplique, resource) } do
    link_to I18n.t("admin.campagnes.action_items.dupliquer"),
           duplique_admin_campagne_path(resource),
           method: :post
  end

  action_item :parametres, only: :show, class: "action_item--sidebar-parametres" do
    render partial: "admin/campagnes/sidebar/parametres"
  end

  action_item :voir_evaluations, only: :show, class: "action_item--lien-consultation" do
    classe_evaluation, chemin_evaluations = if resource.evapro?
      [ EvaluationEvapro, admin_evaluations_evapro_path(q: { campagne_id_eq: resource }) ]
    else
      [ EvaluationEva, admin_evaluations_eva_path(q: { campagne_id_eq: resource }) ]
    end
    nombre = classe_evaluation.accessible_by(current_ability).where(campagne: resource).count

    render LienComponent.new(
      I18n.t("admin.campagnes.action_items.voir_evaluations", count: nombre),
      chemin_evaluations,
      class: "fr-link fr-link--icon-left fr-icon-file-line"
    )
  end

  action_item :voir_beneficiaires, only: :show, class: "action_item--lien-consultation",
              if: proc { can?(:read, Beneficiaire) } do
    nombre = Beneficiaire.accessible_by(current_ability)
                         .joins(:evaluations)
                         .where(evaluations: { campagne_id: resource.id })
                         .distinct
                         .count
    render LienComponent.new(
      I18n.t("admin.campagnes.action_items.voir_beneficiaires", count: nombre),
      admin_beneficiaires_path(q: { evaluations_campagne_id_eq: resource.id }),
      class: "fr-link fr-link--icon-left fr-icon-team-line"
    )
  end

  member_action :duplique, method: :post do
    campagne_dupliquee = CampagneDuplicateur.new(resource, current_compte).duplique!
    redirect_to admin_campagne_path(campagne_dupliquee),
      notice: I18n.t("admin.campagnes.duplique.notice")
  end

  member_action :autoriser_compte, method: :post do
    compte = Compte.find_by(id: params["compte_id"])
    resource.campagne_compte_autorisations.create!(compte_id: compte.id) if compte.present?
    redirect_to admin_campagne_path(resource)
  end

  member_action :revoquer_compte, method: :patch do
    CampagneCompteAutorisation
      .find_by(campagne_id: resource.id, compte_id: params["compte_id"])&.really_destroy!
    head :no_content
  end

  sidebar :acces_prives, only: :show,
    if: proc { (resource.campagne_compte_autorisations.present? ||
                can?(:autoriser_compte, resource)) &&
               resource.privee } do
    render "aide_acces_prives"
    resource.campagne_compte_autorisations.joins(:compte).includes(:compte).each do |autorisation|
      url = revoquer_compte_admin_campagne_path(
        resource,
        compte_id: autorisation.compte.id)
      render(TagComponent.new(libelle: autorisation.compte.display_name,
                              supprimable: can?(:revoquer_compte, resource),
                              url: url,
                              taille: :sm))
    end
    render "components/recherche_comptes_structure" if can?(:autoriser_compte, resource)
  end

  show do
    render partial: "show"
  end

  form partial: "form"

  controller do
    helper_method :comptes_structure, :comptes_structures_filles

    before_action :assigne_valeurs_par_defaut, only: %i[new create]
    before_action :parcours_type, only: %i[new create edit update]
    before_action :situations_configurations, only: %i[show]
    before_action :entete_index, only: :index

    def create
      create!
      flash[:notice] = I18n.t("admin.campagnes.show.nouvelle_campagne") if resource.save
    end

    def show
      show!
    end

    private

    def entete_index
      @page_title = active_admin_config.plural_resource_label
      @page_dsfr = true
      @entete_dsfr = true
      @filtres = Campagnes::FiltresListe.new(params[:q], current_compte)
    end

    def scoped_collection
      collection = end_of_association_chain.avec_nombre_evaluations_et_derniere_evaluation
      if liste_avec_structures?
        collection.left_joins(compte: :structure)
                  .includes(compte: :structure)
                  .group("comptes.id", "structures.id")
      elsif charge_les_comptes?
        collection.includes(:compte)
      else
        collection
      end
    end

    def liste_avec_structures?
      (current_compte.anlci? || current_compte.administratif?) && action_name == "index"
    end

    # La liste HTML affiche le compte de chaque campagne ; la recherche JSON, non
    def charge_les_comptes?
      can?(:manage, Compte) || (action_name == "index" && request.format.html?)
    end

    def find_resource
      scoped_collection.where(id: params[:id]).first!
    end

    def assigne_valeurs_par_defaut
      params[:campagne] ||= {}
      params[:campagne][:compte_id] ||= current_compte.id unless current_compte.administratif?
    end

    def parcours_type
      @parcours_type ||= ParcoursType.where(actif: true).order(:position, :created_at)
    end

    def situations_configurations
      @situations_configurations ||= resource
                                     .situations_configurations
                                     .includes([ :questionnaire,
                                                { situation: %i[questionnaire
                                                                illustration_attachment] } ])
    end

    def comptes_structures_filles
      return Compte.none unless current_compte.structure

      structures_locales_filles = current_compte.structure.structures_locales_filles
      @comptes_structures_filles ||= Compte.where(structure: structures_locales_filles)
                                           .where.not(statut_validation: :refusee)
                                           .order(:prenom, :nom)
    end

    def comptes_structure
      @compte_structure ||= Compte.de_la_structure(resource.compte&.structure).order(:prenom, :nom)
    end
  end
end
