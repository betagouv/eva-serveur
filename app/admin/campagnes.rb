# frozen_string_literal: true

ActiveAdmin.register Campagne do
  menu priority: 3, if: proc { current_compte.structure_id.present? && can?(:read, Campagne) }

  permit_params :libelle, :code, :compte, :active, :privee,
                :compte_id, :affiche_competences_fortes, :parcours_type_id, :type_programme,
                options_personnalisation: [],
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  config.sort_order = "created_at_desc"

  includes :parcours_type

  filter :libelle
  filter :code
  filter :compte_id,
         as: :search_select_filter,
         url: proc { admin_comptes_path },
         fields: %i[email nom prenom],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "email_asc"
  filter :situations
  filter :created_at

  action_item :nouvelle_campagne_disabled, only: :index,
              if: proc { current_compte.structure_id.present? && !can?(:create, Campagne) &&
                         !current_compte.structure.autorisation_creation_campagne? } do
    div class: "fr-mb-2v" do
      link_to(I18n.t("admin.campagnes.action_items.nouvelle_campagne_disabled"), "#",
class: "bouton-disabled")
    end
    span I18n.t("admin.campagnes.action_items.nouvelle_campagne_disabled_explication"),
  class: "fr-text--xs text-grey-425"
  end

  action_item :dupliquer, only: :show, if: proc { can?(:duplique, resource) } do
    link_to I18n.t("admin.campagnes.action_items.dupliquer"),
           duplique_admin_campagne_path(resource),
           method: :post
  end

  action_item :voir_evaluations, only: :show do
    link_to I18n.t("admin.campagnes.action_items.voir_evaluations",
           count: Evaluation.where(campagne: resource).count),
           admin_evaluations_path(q: { campagne_id_eq: resource })
  end

  action_item :parametres, only: :show, class: "action_item--sidebar-parametres" do
    render partial: "admin/campagnes/sidebar/parametres"
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
    redirect_to request.referer
  end

  sidebar :acces_prives, only: :show,
    if: proc { (resource.campagne_compte_autorisations.present? ||
                can?(:autoriser_compte, resource)) &&
               resource.privee } do
    render "aide_acces_prives"
    resource.campagne_compte_autorisations.each do |autorisation|
      url = revoquer_compte_admin_campagne_path(
        resource,
        compte_id: autorisation.compte.id)
      render(Tag.new(autorisation.compte.display_name,
                     classes: "bleu",
                     supprimable: can?(:revoquer_compte, resource),
                     url: url))
    end
    render "components/recherche_comptes_structure" if can?(:autoriser_compte, resource)
  end

  index do
    column :libelle do |campagne|
      div class: "contenu-libelle" do
        div do
          div link_to(campagne.libelle, admin_campagne_path(campagne))
          div parcours_type_libelle(campagne), class: "text-xs"
        end
        div do
          render(StatutCampagneComponent.new(campagne_active: campagne.active,
campagne_privee: campagne.privee))
        end
      end
    end
    column :code
    column :nombre_evaluations, class: "col-nombre_evaluations text-right",
                                sortable: :nombre_evaluations
    column :date_derniere_evaluation, sortable: :date_derniere_evaluation do |campagne|
      l(campagne.date_derniere_evaluation, format: :sans_heure) if campagne.date_derniere_evaluation
    end
    column :compte if can?(:manage, Compte)
    column :created_at
    actions
  end

  show do
    render partial: "show"
  end

  form partial: "form"

  controller do
    helper_method :comptes_structure

    before_action :assigne_valeurs_par_defaut, only: %i[new create]
    before_action :parcours_type, only: %i[new create edit update]
    before_action :situations_configurations, only: %i[show]

    def create
      create!
      flash[:notice] = I18n.t("admin.campagnes.show.nouvelle_campagne") if resource.save
    end

    def show
      show!
    end

    private

    def scoped_collection
      collection = end_of_association_chain.avec_nombre_evaluations_et_derniere_evaluation
      can?(:manage, Compte) ? collection.includes(:compte) : collection
    end

    def find_resource
      scoped_collection.where(id: params[:id]).first!
    end

    def assigne_valeurs_par_defaut
      params[:campagne] ||= {}
      params[:campagne][:compte_id] ||= current_compte.id
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

    def comptes_structure
      @compte_structure ||= Compte.de_la_structure(resource.compte.structure).order(:prenom, :nom)
    end
  end
end
