# frozen_string_literal: true

ActiveAdmin.register Beneficiaire do
  permit_params :nom

  filter :nom
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
end
