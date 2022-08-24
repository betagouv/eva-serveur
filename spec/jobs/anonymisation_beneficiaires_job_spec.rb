# frozen_string_literal: true

require 'rails_helper'

describe AnonymisationBeneficiairesJob, type: :job do
  it "n'anonymise pas les bénéficiaires qui ont des évaluations de moins d'un an" do
    beneficiaire = create :beneficiaire, nom: 'nom'
    ancienne_evaluation = create :evaluation, created_at: 2.years.ago, beneficiaire: beneficiaire
    evaluation_recente = create :evaluation, created_at: 11.months.ago, beneficiaire: beneficiaire

    AnonymisationBeneficiairesJob.perform_now

    ancienne_evaluation.reload
    evaluation_recente.reload

    expect(ancienne_evaluation.anonymise_le).to be_nil
    expect(evaluation_recente.anonymise_le).to be_nil
  end

  it "anonymise les bénéficiaires qui ont des évaluations de plus d'un an" do
    beneficiaire = create :beneficiaire, nom: 'nom'
    ancienne_evaluation = create :evaluation, created_at: 2.years.ago, beneficiaire: beneficiaire
    evaluation_recente = create :evaluation, created_at: 16.months.ago, beneficiaire: beneficiaire

    AnonymisationBeneficiairesJob.perform_now

    ancienne_evaluation.reload
    evaluation_recente.reload

    expect(ancienne_evaluation.anonymise_le).not_to be_nil
    expect(evaluation_recente.anonymise_le).not_to be_nil
  end
end
