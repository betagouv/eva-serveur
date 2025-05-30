# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  permit_params :campagne_id, :nom, :beneficiaire_id, :statut, :responsable_suivi_id
  menu priority: 4, if: proc { current_compte.structure_id.present? && can?(:read, Evaluation) }

  includes :responsable_suivi, campagne: [ :parcours_type ]

  config.sort_order = "created_at_desc"

  filter :nom
  filter :campagne_id,
         as: :search_select_filter,
         url: proc { admin_campagnes_path },
         fields: %i[libelle code],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "libelle_asc"
  filter :created_at
  filter :responsable_suivi_id,
         as: :search_select_filter,
         url: proc { admin_comptes_path },
         fields: %i[email nom prenom],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "email_asc"
  filter :statut,
         as: :select,
         collection: Evaluation.statuts.map { |v, id|
           [ Evaluation.human_enum_name(:statut, v), id ]
         },
         if: proc { current_compte.superadmin? }

  scope proc { I18n.t("activerecord.scopes.evaluation.all") }, :all, default: true
  scope proc {
          render(PastilleComponent.new(
                   couleur: "alerte",
                   etiquette: I18n.t("components.pastille.illettrisme_potentiel")
                 ))
        }, :illettrisme_potentiel

  show do
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: "show"
  end

  index download_links: -> { params[:action] == "show" ? %i[pdf] : %i[xls] },
        row_class: ->(elem) { "anonyme" if elem.anonyme? } do
    render "index", context: self
  end

  form partial: "form"

  sidebar :responsable_de_suivi, only: :show, if: proc { resource.responsable_suivi.present? } do
    render(Tag.new(resource.responsable_suivi.display_name,
                   supprimable: can?(:supprimer_responsable_suivi, Evaluation),
                   url: supprimer_responsable_suivi_admin_evaluation_path(resource)))
  end

  sidebar :responsable_de_suivi, only: :show, if: proc {
                                                    resource.responsable_suivi.blank? and
                                                      can?(:ajouter_responsable_suivi, Evaluation)
                                                  } do
    render "recherche_responsable_suivi"
  end

  sidebar :menu, class: "menu-sidebar", only: :show

  xls(i18n_scope: %i[active_admin xls evaluation]) do
    whitelist
    column("structure") { |evaluation| evaluation.campagne&.structure&.nom }
    column(:campagne) { |evaluation| evaluation.campagne&.libelle }
    column(:created_at) { |evaluation| I18n.l(evaluation.created_at, format: :sans_heure) }
    column :nom
    column(:completude) do |evaluation|
      I18n.t(evaluation.completude, scope: "activerecord.attributes.evaluation")
    end
    column(:synthese_competences_de_base) { |e| trad_niveau(e, :synthese_competences_de_base) }
    column(:niveau_cefr) { |evaluation| trad_niveau(evaluation, :niveau_cefr) }
    column(:niveau_cnef) { |evaluation| trad_niveau(evaluation, :niveau_cnef) }
    column(:niveau_anlci_litteratie) { |e| trad_niveau(e, :niveau_anlci_litteratie) }
    column(:niveau_anlci_numeratie) { |e| trad_niveau(e, :niveau_anlci_numeratie) }
    column(:positionnement_niveau_litteratie) do |evaluation|
      trad_niveau(evaluation, :positionnement_niveau_litteratie)
    end
    column(:positionnement_niveau_numeratie) do |evaluation|
      trad_niveau(evaluation, :positionnement_niveau_numeratie)
    end

    before_filter do |sheet|
      if @collection.count > Evaluation::LIMITE_EXPORT_XLS
        sheet << [
          I18n.t("active_admin.export.limite_atteinte", limite: Evaluation::LIMITE_EXPORT_XLS)
        ]
        @collection = @collection.limit!(Evaluation::LIMITE_EXPORT_XLS)
      end
    end
  end

  member_action :mise_en_action, method: :put do
    resource.enregistre_mise_en_action(params[:mise_en_action_effectuee])
  end

  member_action :supprimer_responsable_suivi, method: :patch do
    resource.update(responsable_suivi: nil)
    redirect_to request.referer
  end

  member_action :ajouter_responsable_suivi, method: :post do
    responsable = Compte.where(id: params["responsable_suivi_id"]).first
    resource.update(responsable_suivi: responsable) if responsable.present?
    redirect_to admin_evaluation_path(resource)
  end

  member_action :renseigner_qualification, method: :patch do
    mise_en_action = resource.mise_en_action
    effectuee = params[:effectuee]
    qualification = params[:qualification]
    if effectuee == "true"
      mise_en_action.update(effectuee: true, remediation: qualification)
    else
      mise_en_action.update(effectuee: false, difficulte: qualification)
    end
  end

  controller do
    helper_method :restitution_globale, :completude, :parties, :prise_en_main?, :bienvenue,
                  :restitution_pour_situation, :statistiques, :mes_avec_redaction_de_notes,
                  :campagnes_accessibles, :beneficiaires_possibles, :trad_niveau,
                  :campagne_avec_competences_transversales?,
                  :responsables_suivi_possibles, :campagne_avec_positionnement?

    def show
      show! do |format|
        format.html
        format.pdf { render_pdf }
      end
    end

    def render_pdf
      html_content = render_to_string(template: "admin/evaluations/show", layout: "application",
                                      locals: { resource: resource })

      pdf_path = Html2Pdf.genere_pdf_depuis_html(html_content)
      if pdf_path == false
        flash[:error] = t(".erreur_generation_pdf")
        redirect_to admin_evaluation_path(resource)
      else
        send_file(pdf_path, filename: "#{resource.nom}.pdf", type: "application/pdf",
                            disposition: disposition)
      end
    end

    def disposition
      Rails.env.development? ? "inline" : "attachment"
    end

    def destroy
      destroy!(location: admin_campagne_path(resource.campagne))
    end

    before_action only: :show do
      flash.now[:evaluation_anonyme] = t(".evaluation_anonyme") if resource.anonyme?
    end

    private

    def find_resource
      scoped_collection.where(id: params[:id])
                       .includes(campagne: { situations_configurations: :situation })
                       .first!
    end

    def statistiques
      @statistiques ||= StatistiquesEvaluation.new(resource)
    end

    def restitution_globale
      @restitution_globale ||=
        FabriqueRestitution.restitution_globale(resource, params[:parties_selectionnees])
    end

    def completude
      @completude ||= Restitution::Completude.new(resource, restitution_globale.restitutions)
    end

    def trad_niveau(evaluation, interpretation)
      scope = "activerecord.attributes.evaluation.interpretations"
      niveau = evaluation.send(interpretation)
      t("#{interpretation}.#{niveau}", scope: scope) if niveau.present?
    end

    def mes_avec_redaction_de_notes
      @mes_avec_redaction_de_notes ||= restitution_globale.restitutions.select do |restitution|
        %w[questions livraison].include?(restitution.situation.nom_technique) &&
          !restitution.questions_redaction.empty?
      end
    end

    def campagne_avec_competences_transversales?
      @evaluation.campagne.avec_competences_transversales?
    end

    def campagne_avec_positionnement?(competence)
      @evaluation.campagne.avec_positionnement?(competence)
    end

    def prise_en_main?
      restitution_globale.selectionne_derniere_restitution(Situation::PLAN_DE_LA_VILLE)&.termine?
    end

    def bienvenue
      restitution_globale.selectionne_derniere_restitution(Situation::BIENVENUE)
    end

    def restitution_pour_situation(situation)
      restitution_globale.selectionne_derniere_restitution(situation)
    end

    def parties
      Partie.where(evaluation_id: resource).includes(:situation).order(:created_at)
    end

    def campagnes_accessibles
      @campagnes_accessibles ||= Campagne.accessible_by(current_ability)
    end

    def responsables_suivi_possibles
      @responsables_suivi_possibles ||= resource.responsables_suivi
    end

    def beneficiaires_possibles
      @beneficiaires_possibles ||= resource.beneficiaires_possibles
    end
  end
end
