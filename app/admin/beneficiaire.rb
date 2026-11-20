ActiveAdmin.register Beneficiaire do
  permit_params :nom

  # Les filtres sont rendus par FiltresComponent dans l'en-tête de la page ; ransack
  # les applique toujours à partir de params[:q]
  config.filters = false
  config.current_filters = false
  config.batch_actions = false

  config.sort_order = "created_at_desc"

  order_by(:statut_suivi) do |clause|
    sens_de_tri = clause.order == "desc" ? "ASC" : "DESC"
    "#{Beneficiaires::StatutSuivi.sql_ordre_de_tri} #{sens_de_tri}"
  end

  collection_action :fusionner, method: :post do
    authorize! :fusionner, Beneficiaire
    beneficiaires = Beneficiaire.where(id: params[:beneficiaire_ids])

    if beneficiaires.size < 2
      redirect_to collection_path, alert: t("admin.beneficiaires.fusion.errors.alert")
      next
    end

    beneficiaire = beneficiaires.par_date_creation_asc.first
    lien = LienBeneficiaires.new(beneficiaire, beneficiaires.sauf_pour(beneficiaire.id))
    lien.call

    redirect_to admin_beneficiaire_path(lien.beneficiaire),
                notice: t("admin.beneficiaires.fusion.success.notice",
                          beneficiaire_nom: lien.beneficiaire.nom)
  end

  collection_action :renseigner_suivi_groupe, method: :post do
    authorize! :renseigner_suivi_groupe, Beneficiaire
    beneficiaire_ids = Array(params[:beneficiaire_ids])
    resultat = Beneficiaires::EnregistreSuiviGroupe.new(
      beneficiaire_ids,
      params[:effectuee],
      params[:qualification].presence,
      params[:precision_autre].presence,
      params[:choix_date_revue].presence,
      params[:date_precise].presence,
      current_compte
    ).call

    if resultat == :effectuee_invalide
      redirect_to collection_path
    else
      redirect_to collection_path(selection: beneficiaire_ids),
                  flash: { success: message_suivi_groupe_enregistre(resultat[:succes]) }
    end
  end

  before_action only: :show do
    flash.now[:beneficiaire_anonyme] = t(".beneficiaire_anonyme") if resource.anonyme?
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :nom
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  show do
    render partial: "show"
  end

  controller do
    before_action :entete_index, only: :index
    before_action :restitutions_positionnement, only: :show
    before_action :evaluations_diagnostic, only: :show
    before_action :evaluation_suivi, only: :show

    def find_resource
      scoped_collection.includes(
                         evaluations: {
                           campagne: [
                             :situations_configurations,
                             :campagne_compte_autorisations,
                             { compte: :structure }
                           ]
                         }
                       )
                       .where(id: params[:id])
                       .first!
    end

    # La sélection (retour du suivi groupé, EVA-1219) ne fait que restreindre
    # le périmètre du compte : elle ne peut pas l'élargir
    def scoped_collection
      beneficiaires = end_of_association_chain.distinct
      return beneficiaires if params[:selection].blank?

      beneficiaires.where(id: Array(params[:selection]))
    end

    def apply_sorting(beneficiaires)
      super(Beneficiaire.where(id: beneficiaires.select(:id)))
    end

    def entete_index
      @page_title = active_admin_config.plural_resource_label
      @page_dsfr = true
      @filtres = Beneficiaires::FiltresListe.new(params[:q], current_compte)
    end

    def restitutions_positionnement
      @restitutions_positionnement ||= evaluations_positionnement.map do |evaluation|
        FabriqueRestitution.restitution_globale(evaluation)
      end
    end

    def evaluations_diagnostic
      @evaluations_diagnostic ||= evaluations_eva_accessibles.diagnostic
                                                             .order(created_at: :desc)
    end

    # La carte "Suivi de l'accompagnement" porte sur la dernière évaluation suivie
    # de la personne : la réponse donnée vaut pour toute sa structure (EVA-1186)
    def evaluation_suivi
      @evaluation_suivi ||= evaluations_eva_accessibles
                              .suivies
                              .order(debutee_le: :desc)
                              .first
    end

    private

    def message_suivi_groupe_enregistre(nombre)
      cles = "admin.beneficiaires.renseigner_suivi_groupe.success"
      "#{t("#{cles}.titre", count: nombre)}\n#{t("#{cles}.texte")}"
    end

    def evaluations_eva_accessibles
      @evaluations_eva_accessibles ||=
        EvaluationEva.accessible_by(current_ability).where(beneficiaire: resource)
    end

    def evaluations_positionnement
      @evaluations_positionnement ||= evaluations_eva_accessibles.positionnement
                                                                 .order(created_at: :desc)
    end
  end
end
