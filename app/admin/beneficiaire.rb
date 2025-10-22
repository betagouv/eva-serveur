ActiveAdmin.register Beneficiaire do
  permit_params :nom

  filter :nom, filters: [ :contains_unaccent, :eq ]
  filter :code_beneficiaire
  filter :created_at
  config.sort_order = "created_at_desc"
  config.batch_actions = true

  batch_action :destroy, false

  batch_action :fusionner, if: proc { can?(:fusionner, Beneficiaire) } do |beneficiaire_ids|
    beneficiaires = Beneficiaire.where(id: beneficiaire_ids)

    if beneficiaires.size < 2
      redirect_to collection_path,
      alert: t(".fusion.errors.alert")
      next
    end

    beneficiaire = beneficiaires.par_date_creation_asc.first
    beneficiaires_a_fusionner = beneficiaires.sauf_pour(beneficiaire.id)

    lien = LienBeneficiaires.new(beneficiaire, beneficiaires_a_fusionner)
    lien.call

    redirect_to admin_beneficiaire_path(lien.beneficiaire),
      notice: t(".fusion.success.notice",
                beneficiaire_nom: lien.beneficiaire.nom)
  end

  before_action only: :show do
    flash.now[:beneficiaire_anonyme] = t(".beneficiaire_anonyme") if resource.anonyme?
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :nom
    end
    f.actions
  end

  show do
    render partial: "show"
  end

  index do
    render "admin/beneficiaires/modal_fusion"
    render "index", context: self
  end

  controller do
    before_action :restitutions_positionnement, only: :show
    before_action :evaluations_diagnostic, only: :show

    def find_resource
      scoped_collection.includes(
                         evaluations: {
                           campagne: [
                             :situations_configurations,
                             :campagne_compte_autorisations,
                             :compte
                           ]
                         }
                       )
                       .where(id: params[:id])
                       .first!
    end

    def scoped_collection
      end_of_association_chain.includes(evaluations: { campagne: :compte })
    end

    def restitutions_positionnement
      @restitutions_positionnement ||= evaluations_positionnement.map do |evaluation|
        FabriqueRestitution.restitution_globale(evaluation)
      end
    end

    def evaluations_diagnostic
      @evaluations_diagnostic ||= evaluations_accessibles.diagnostic
      .includes([ :campagne ])
      .order(created_at: :desc)
    end

    private

    def evaluations_accessibles
      @evaluations_accessibles ||= resource.evaluations.accessible_by(current_ability)
    end

    def evaluations_positionnement
      @evaluations_positionnement ||= evaluations_accessibles.positionnement
                                                             .includes([ :campagne ])
                                                             .order(created_at: :desc)
    end
  end
end
