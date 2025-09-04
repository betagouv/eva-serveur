# frozen_string_literal: true

ActiveAdmin.register Beneficiaire do
  permit_params :nom

  filter :nom
  filter :code_beneficiaire
  filter :created_at
  config.sort_order = "created_at_desc"
  config.batch_actions = true

  batch_action :lier, if: proc { can?(:lier, Beneficiaire) } do |beneficiaire_ids|
    beneficiaires = Beneficiaire.where(id: beneficiaire_ids)

    if beneficiaires.size < 2
      redirect_to collection_path, alert: "Sélectionnez au moins deux bénéficiaires pour les lier."
      next
    end

    beneficiaire = beneficiaires.par_date_creation_asc.first
    beneficiaires_a_fusionner = beneficiaires.sauf_pour(beneficiaire.id)

    lien = LienBeneficiaires.new(beneficiaire, beneficiaires_a_fusionner)
    lien.call

    redirect_to admin_beneficiaire_path(lien.beneficiaire),
        notice: "Les évaluations ont été transférées vers le bénéficiaire le plus ancien."
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
    selectable_column if can?(:lier, Beneficiaire)
    column :nom do |beneficiaire|
      render partial: "nom_beneficiaire", locals: { beneficiaire: beneficiaire }
    end
    column :code_beneficiaire
    column :created_at
    actions
  end
end
