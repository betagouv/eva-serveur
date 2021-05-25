# frozen_string_literal: true

require 'rails_helper'

describe AnonymisationEvaluationsJob, type: :job do
  it "anonymise les évaluations de plus d'un an" do
    ancienne_evaluation = create :evaluation, created_at: 2.years.ago
    evaluation_recente = create :evaluation, created_at: 11.month.ago
    evaluation_deja_anonymise = create :evaluation, anonymise_le: 1.month.ago,
                                                    created_at: 2.years.ago,
                                                    nom: 'deja anonymise'

    AnonymisationEvaluationsJob.perform_now

    ancienne_evaluation.reload
    evaluation_recente.reload

    expect(ancienne_evaluation.anonymise_le).not_to be_nil
    expect(evaluation_recente.anonymise_le).to be_nil
    expect(evaluation_deja_anonymise.nom).to eq 'deja anonymise'
  end
end
