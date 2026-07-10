ActiveAdmin.register EvaluationEvapro do
  actions :all, except: [ :edit, :update ]

  permit_params :campagne_id, :nom, :beneficiaire_id, :statut, :responsable_suivi_id

  includes :beneficiaire, campagne: [ :parcours_type, compte: [ :structure ] ]

  config.sort_order = "created_at_desc"

  filter :beneficiaire_id,
         label: I18n.t("admin.evaluation_evapros.index.colonne_par"),
         as: :search_select_filter,
         url: proc { admin_beneficiaires_path },
         fields: %i[nom],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "nom_asc"
  filter :debutee_le

  show do
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: "show"
  end

  index download_links: -> { params[:action] == "show" ? %i[pdf] : %i[xls] },
        row_class: ->(elem) { "anonyme" if elem.anonyme? },
        dsfr_table: proc { true } do
      render "index", context: self
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
        structure: structure
      }
  end

  xls(i18n_scope: %i[active_admin xls evaluation], header_format: { weight: :bold }) do
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
    include Admin::DashboardHelper

    helper_method :restitution_globale, :completude, :parties,
                  :restitution_pour_situation, :statistiques,
                  :campagnes_accessibles, :beneficiaires_possibles,
                  :comptes_externes_possibles, :structure,
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
      html_content = render_to_string(template: "admin/evaluations/show", layout: "application",
                                      locals: { resource: resource })

      pdf_path = Pdf::Generator.generate(html_content)

      if pdf_path == false
        flash[:error] = t(".erreur_generation_pdf")
        redirect_to admin_evaluation_path(resource)
      else
        envoyer_fichier(pdf_path)
      end
    end

    def envoyer_fichier(pdf_path)
      send_file(pdf_path,
                filename: nom_fichier(resource.debutee_le, resource.beneficiaire.nom, "pdf"),
                type: "application/pdf",
                disposition: Rails.env.development? ? "inline" : "attachment")
    end

    def destroy
      location = if request.referer&.include?("?")
                   request.referer
      elsif request.referer&.include?(admin_beneficiaire_path(resource.beneficiaire))
                   request.referer
      else
                   admin_evaluations_path
      end
      destroy!(location: location)
    end

    before_action only: :show do
      flash.now[:evaluation_anonyme] = t(".evaluation_anonyme") if resource.anonyme?
    end

    def structure
      current_compte.structure
    end

    def syntheses_evapro_par_evaluation_id
      @syntheses_evapro_par_evaluation_id ||= SynthesesEvaproPourIndex.pour(collection)
    end

    private

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

      ::Evaluations::DiagnosticPro::SCORE_TO_LETTRE.fetch(niveau)
    end

    def score_cout_pour_xls(evaluation)
      cout_presenter = cout_presenter_pour(evaluation, synthese_evapro_pour_xls(evaluation))
      return if cout_presenter.nil?

      cout_presenter.contenu_cout[:titre]
    end

    def remplir_syntheses_evapro_pour_index
      return unless current_compte.utilisateur_entreprise?

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

    def completude
      @completude ||= Restitution::Completude.new(resource, restitution_globale.restitutions)
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

    def comptes_externes_possibles
      @comptes_externes_possibles ||= resource.comptes_externes_possibles
    end

    def beneficiaires_possibles
      @beneficiaires_possibles ||= resource.beneficiaires_possibles
    end
  end
end
