ActiveAdmin.register Beneficiaire do
  permit_params :nom

  liste_dsfr

  filter :nom, filters: [ :contains_unaccent, :eq ]
  filter :code_beneficiaire
  filter :evaluations_campagne_compte_structure_id,
         as: :search_select_filter,
         url: proc { admin_structures_path },
         fields: %i[nom code_postal],
         display_name: "display_name",
         minimum_input_length: 2,
         order_by: "lower_nom_asc",
         label: proc { Structure.model_name.human },
         method_model: Structure,
         if: proc { current_compte.anlci? || current_compte.administratif? }
  filter :evaluations_campagne_id,
         as: :search_select_filter,
         url: proc { admin_campagnes_path },
         fields: %i[libelle code],
         display_name: "libelle",
         minimum_input_length: 2,
         order_by: "libelle_asc",
         label: proc { Campagne.model_name.human },
         method_model: Campagne
  filter :statut_suivi,
         as: :selection_multiple_filter,
         traduction_nombre_choisis: "statut_suivi.nombre_statuts",
         collection: proc {
           EvaluationsEva::StatutSuivi::STATUTS_FILTRE.map { |statut|
             [ I18n.t("statut_suivi.#{statut}"), statut ]
           }
         }
  filter :created_at

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
      redirect_to collection_path,
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

    def scoped_collection
      end_of_association_chain.distinct
    end

    def apply_sorting(beneficiaires)
      super(Beneficiaire.where(id: beneficiaires.select(:id)))
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
