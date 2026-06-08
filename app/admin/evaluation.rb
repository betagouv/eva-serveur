ActiveAdmin.register Evaluation do
  permit_params :campagne_id, :nom, :beneficiaire_id, :statut, :responsable_suivi_id
  menu priority: 4, if: proc { current_compte.structure_id.present? && can?(:read, Evaluation) }

  includes :beneficiaire, campagne: [ :parcours_type, compte: [ :structure ] ]

  config.sort_order = "created_at_desc"

  filter :beneficiaire_id,
         label: Evaluation.human_attribute_name("beneficiaire"),
         as: :search_select_filter,
         url: proc { admin_beneficiaires_path },
         fields: %i[nom code_beneficiaire],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "nom_asc",
         if: proc { !current_compte.utilisateur_entreprise? }
  filter :campagne_compte_structure_id,
         as: :search_select_filter,
         url: proc { admin_structures_locales_path },
         fields: %i[nom code_postal],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "nom_asc",
         label: proc { StructureLocale.model_name.human },
         method_model: StructureLocale,
         if: proc {
 current_compte.anlci? || current_compte.administratif? && !current_compte.utilisateur_entreprise? }
  filter :campagne_id,
         as: :search_select_filter,
         url: proc { admin_campagnes_path },
         fields: %i[libelle code],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "libelle_asc",
         if: proc { !current_compte.utilisateur_entreprise? }
  filter :debutee_le, if: proc { !current_compte.utilisateur_entreprise? }
  filter :responsable_suivi_id,
         label: Evaluation.human_attribute_name("responsable_suivi"),
         as: :search_select_filter,
         url: proc { admin_comptes_path },
         fields: %i[email nom prenom],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "email_asc",
         if: proc { !current_compte.utilisateur_entreprise? }
  filter :statut,
         as: :select,
         collection: Evaluation.statuts.map { |v, id|
           [ Evaluation.human_enum_name(:statut, v), id ]
         },
         if: proc { current_compte.superadmin? && !current_compte.utilisateur_entreprise? }

         scope proc {
 I18n.t("activerecord.scopes.evaluation.all") }, :all, default: true, if: proc {
          !current_compte.utilisateur_entreprise? }
  scope proc {
          render(PastilleComponent.new(
                   couleur: "alerte",
                   etiquette: I18n.t("components.pastille.illettrisme_potentiel")
                 ))
        }, :illettrisme_potentiel, if: proc { !current_compte.utilisateur_entreprise? }

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

  sidebar " ", class: "menu-sidebar", only: :show, if: proc { resource.evapro? } do
    render "admin/evaluations/evapro/opco_financeur",
           opco: resource.diagnostic_pro&.opco_financeur,
           evaluation: resource
  end

  sidebar :responsable_de_suivi, only: :show, if: proc {
    !resource.evapro? && resource.responsable_suivi.present?
  } do
    render(Tag.new(resource.responsable_suivi.display_name,
                   classes: "bleu",
                   supprimable: can?(:supprimer_responsable_suivi, Evaluation),
                   url: supprimer_responsable_suivi_admin_evaluation_path(resource)))
  end

  sidebar :responsable_de_suivi, only: :show, if: proc {
    !resource.evapro? &&
      resource.responsable_suivi.blank? &&
      can?(:ajouter_responsable_suivi, Evaluation)
  } do
    render "admin/evaluations/eva/recherche_responsable_suivi"
  end

  sidebar :menu, class: "menu-sidebar", only: :show, if: proc { !resource.evapro? } do
    render "admin/evaluations/eva/menu_sidebar"
  end

  sidebar " ", class: "menu-sidebar evaluation-evapro", only: :index, if: proc {
    current_compte.utilisateur_entreprise? } do
           render partial: "admin/evaluations/evapro/index_evapro/sidebar_opco",
                 locals: {
                   opco: opco_financeur,
                   structure: structure
                 }
     end

  member_action :supprimer_responsable_suivi, method: :patch do
    resource.update(responsable_suivi: nil)
    redirect_to request.referer
  end

  xls(i18n_scope: %i[active_admin xls evaluation], header_format: { weight: :bold }) do
    whitelist
    column("structure") { |evaluation| evaluation.campagne&.structure&.nom }
    column(:campagne) { |evaluation| evaluation.campagne&.libelle }
    column(:debutee_le) { |evaluation| I18n.l(evaluation.debutee_le, format: :sans_heure) }
    column("nom_beneficiaire") { |evaluation| evaluation.beneficiaire.nom }
    column("par") { |evaluation| evaluation.beneficiaire.nom }
    column("code_beneficiaire") { |evaluation| evaluation.beneficiaire.code_beneficiaire }
    column(:completude) do |evaluation|
      I18n.t(evaluation.completude, scope: "activerecord.attributes.evaluation")
    end
    column(:synthese_competences_de_base) { |e| trad_niveau(e, :synthese_competences_de_base) }
    column(:niveau_cefr) { |evaluation| trad_niveau(evaluation, :niveau_cefr) }
    column(:niveau_cnef) { |evaluation| trad_niveau(evaluation, :niveau_cnef) }
    column(:niveau_anlci_litteratie) { |e| trad_niveau(e, :niveau_anlci_litteratie) }
    column(:niveau_anlci_numeratie) { |e| trad_niveau(e, :niveau_anlci_numeratie) }
    column(:positionnement_niveau_litteratie) { |e|
      trad_niveau(e, :positionnement_niveau_litteratie) }
    column(:positionnement_niveau_numeratie) { |e|
      trad_niveau(e, :positionnement_niveau_numeratie) }
    column("reponses_redaction") do |evaluation|
      evaluation.redactions
        &.map
        &.with_index(1) { |reponse, index|
          I18n.t("active_admin.xls.evaluation.redaction", index: index, reponse: reponse)
        }
        &.join("\n-----\n")
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
      xls_configuration.masquer_colonnes_non_visibles(sheet: sheet, compte: current_compte)
      xls_configuration.appliquer_limite!(sheet: sheet, collection: @collection)
    end
  end

  member_action :mise_en_action, method: :put do
    effectuee = params[:mise_en_action_effectuee]  == "true"
    resource.passation_beneficiaire&.enregistre_mise_en_action(effectuee)
  end


  member_action :ajouter_responsable_suivi, method: :post do
    responsable = Compte.find_by(id: params["responsable_suivi_id"])
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
    include Fichier
    include Admin::DashboardHelper

    helper_method :restitution_globale, :completude, :parties, :prise_en_main?, :bienvenue,
                  :restitution_pour_situation, :statistiques, :mes_avec_redaction_de_notes,
                  :campagnes_accessibles, :beneficiaires_possibles, :trad_niveau,
                  :campagne_avec_competences_transversales?,
                  :responsables_suivi_possibles, :campagne_avec_positionnement?,
                  :comptes_externes_possibles, :opco_financeur, :structure,
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

    def opco_financeur
      @opco_financeur ||= current_compte.structure&.opco_financeur
    end

    def structure
      current_compte.structure
    end

    def syntheses_evapro_par_evaluation_id
      return {} unless current_compte.utilisateur_entreprise?

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

      palier = {
        "A" => "A - Très bon",
        "B" => "B - Bon",
        "C" => "C - Moyen",
        "D" => "D - Mauvais"
      }[lettre_risque]
      return if palier.blank?

      I18n.t(palier, scope: "bilan_eva_pro.chiffre_cle")
    end

    def impact_evapro_pour_xls(evaluation, cle)
      niveau = syntheses_evapro_par_evaluation_id.dig(evaluation.id, :synthese_impact, cle)
      return if niveau.blank?

      lettre = ::Evaluations::DiagnosticPro::CoutsPresenter.new(synthese: {}, i18n: I18n)
        .score_to_lettre(niveau).upcase
      return if lettre.blank?

      lettre
    end

    def score_cout_pour_xls(evaluation)
      lettre_cout = lettre_couts_pour(evaluation, synthese_evapro_pour_xls(evaluation))
      return if lettre_cout.blank?

      I18n.t(lettre_cout.downcase,
             scope: "admin.evaluations.evapro.impact_couts.contenu_cout.titre")
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

    def comptes_externes_possibles
      @comptes_externes_possibles ||= resource.comptes_externes_possibles
    end

    def beneficiaires_possibles
      @beneficiaires_possibles ||= resource.beneficiaires_possibles
    end
  end
end
