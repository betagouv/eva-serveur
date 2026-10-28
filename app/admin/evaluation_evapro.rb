ActiveAdmin.register EvaluationEvapro do
  actions :all, except: [ :edit, :update ]

  permit_params :campagne_id, :nom, :beneficiaire_id

  includes :beneficiaire, campagne: [ :parcours_type, compte: [ :structure ] ]

  config.sort_order = "created_at_desc"

  filter :beneficiaire_id,
         label: I18n.t("admin.evaluations_evapro.index.colonne_par"),
         as: :search_select_filter,
         url: proc { admin_beneficiaires_path },
         fields: %i[nom],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "nom_asc"
  filter :campagne_compte_structure_id,
         as: :search_select_filter,
         url: proc { admin_structures_locales_path },
         fields: %i[nom code_postal],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "nom_asc",
         label: proc { StructureLocale.model_name.human },
         method_model: StructureLocale,
         if: proc { current_compte.anlci? || current_compte.administratif? }
  filter :debutee_le

  show do
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: "show"
  end

  index download_links: -> { params[:action] == "show" ? %i[pdf] : %i[xls] },
        row_class: ->(elem) { "anonyme" if elem.anonyme? },
        dsfr_table: proc { true }, class: "fr-table--multiline" do
      render "index", context: self
  end

  member_action :telecharger_attestation, method: :get do
    render_attestation_pdf
  end

  action_item :telecharger_attestation, only: :show,
              if: proc {
                AttestationPassation.new(resource).disponible? &&
                  can?(:telecharger_attestation, resource)
              } do
    render BoutonDsfrComponent.new(
      telecharger_attestation_admin_evaluation_evapro_path(resource),
      type: :secondary,
      size: :sm,
      class: "fr-icon-download-line fr-btn--icon-left lien-export-pdf",
      "aria-label":
        I18n.t("admin.evaluations_evapro.action_items.telecharger_attestation.aria_label")
    ).with_content(I18n.t("admin.evaluations_evapro.action_items.telecharger_attestation.libelle"))
  end

  action_item :exporter, only: :show,
              if: proc { resource.restitution_pro(restitution_globale).pourcentage_risque } do
    render BoutonDsfrComponent.new(
      admin_evaluation_evapro_path(resource, format: :pdf),
      type: :primary,
      size: :sm,
      class: "fr-icon-download-line fr-btn--icon-left lien-export-pdf"
    ).with_content(I18n.t("admin.evaluations_evapro.action_items.exporter"))
  end

  form partial: "form"

  sidebar " ", only: :show do
    render partial: "sidebar_evaluation",
      locals: {
        evaluation: resource
      }
  end

  sidebar " ", only: :index do
    render partial: "sidebar_structure",
      locals: {
        structure: current_compte.structure
      }
  end

  xls(i18n_scope: %i[active_admin xls evaluation_evapro], header_format: { weight: :bold }) do
    whitelist
    column("structure") { |evaluation| evaluation.campagne&.structure&.nom }
    column(:campagne) { |evaluation| evaluation.campagne&.libelle }
    column(:debutee_le) { |evaluation| I18n.l(evaluation.debutee_le, format: :sans_heure) }
    column("par") { |evaluation| evaluation.beneficiaire.nom }
    column(:completude) do |evaluation|
      I18n.t(evaluation.completude, scope: "activerecord.attributes.evaluation")
    end
    column("taux_risque") { |e| taux_risque_pour_xls(e) }
    column("performance_collective") { |e| impact_evapro_pour_xls(e, :performance_collective) }
    column("agilite_organisationnelle") { |e|
      impact_evapro_pour_xls(e, :agilite_organisationnelle) }
    column("securite_qualite") { |e| impact_evapro_pour_xls(e, :securite_qualite) }
    column("mobilite_professionnelle") { |e| impact_evapro_pour_xls(e, :mobilite_professionnelle) }
    column("score_cout") { |e| score_cout_pour_xls(e) }
    column("bilan_situation") { |e| recommandation_risque_pour_xls(e) }

    before_filter do |sheet|
      xls_configuration = Admin::Evaluations::XlsConfiguration.new
      xls_configuration.appliquer_limite!(sheet: sheet, collection: @collection)
    end
  end

  controller do
    include Fichier
    include PdfGenerationResponder
    include Admin::DashboardHelper
    include Admin::EvaluationHelper

    helper_method :restitution_globale, :parties,
                  :statistiques,
                  :syntheses_evapro_par_evaluation_id, :taux_risque_pour_xls,
                  :recommandation_risque_pour_xls,
                  :impact_evapro_pour_xls, :score_cout_pour_xls

    before_action :remplir_syntheses_evapro_pour_index, only: :index

    def show
      show! do |format|
        format.html
        format.pdf { render_pdf }
      end
    end

    def render_pdf
      genere_pdf(template: "admin/evaluations_evapro/show",
                 titre: resource.beneficiaire.nom,
                 locals: { resource: resource })
    end

    def render_attestation_pdf
      return head(:not_found) unless AttestationPassation.active?

      genere_pdf(template: "admin/evaluations_evapro/attestation",
                 titre: "attestation-passation-#{resource.beneficiaire.nom}",
                 locals: { evaluation: resource })
    end

    before_action only: :show do
      if resource.anonyme?
        flash.now[:evaluation_anonyme] = t("admin.evaluations.evaluation_anonyme")
      end
    end

    def syntheses_evapro_par_evaluation_id
      @syntheses_evapro_par_evaluation_id ||= SynthesesEvaproPourIndex.pour(collection)
    end

    private

    def genere_pdf(template:, titre:, locals:)
      html_content = String.new(render_to_string(
        template: template, layout: "application", formats: [ :pdf ], locals: locals
      ))
      demarre_generation_pdf(html_content, nom_fichier(resource.debutee_le, titre, "pdf"))
    end

    def taux_risque_pour_xls(evaluation)
      pourcentage = syntheses_evapro_par_evaluation_id.dig(evaluation.id, :pourcentage_risque)
      pourcentage.present? ? "#{pourcentage} %" : nil
    end

    def recommandation_risque_pour_xls(evaluation)
      lettre_risque = lettre_risque_pour(evaluation, synthese_evapro_pour_xls(evaluation))
      return if lettre_risque.blank?

      I18n.t(lettre_risque, scope: "bilan_eva_pro.chiffre_cle")
    end

    def impact_evapro_pour_xls(evaluation, cle)
      niveau = syntheses_evapro_par_evaluation_id.dig(evaluation.id, :synthese_impact, cle)
      return if niveau.blank?

      ::EvaluationEvapro::SCORE_TO_LETTRE.fetch(niveau)
    end

    def score_cout_pour_xls(evaluation)
      cout_presenter = cout_presenter_pour(evaluation, synthese_evapro_pour_xls(evaluation))
      return if cout_presenter.nil?

      cout_presenter.contenu_cout[:titre]
    end

    def remplir_syntheses_evapro_pour_index
      @syntheses_evapro_par_evaluation_id = SynthesesEvaproPourIndex.pour(collection)
    end

    def synthese_evapro_pour_xls(evaluation)
      synthese_evapro = syntheses_evapro_par_evaluation_id[evaluation.id] || {}
      {
        pourcentage_risque: synthese_evapro[:pourcentage_risque],
        score_cout: synthese_evapro[:score_cout]
      }
    end

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

    def parties
      Partie.where(evaluation_id: resource).includes(:situation).order(:created_at)
    end
  end
end
