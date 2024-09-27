# frozen_string_literal: true

require 'rails_helper'

describe AnonymisationEvaluationsJob, type: :job do
  it "anonymise les évaluations de plus d'un an" do
    ancienne_evaluation = create :evaluation, created_at: 1.year.ago
    evaluation_recente = create :evaluation, created_at: 1.year.ago + 1.day
    evaluation_deja_anonymise = create :evaluation, anonymise_le: 1.year.ago,
                                                    created_at: 2.years.ago,
                                                    nom: 'deja anonymise'

    described_class.perform_now

    ancienne_evaluation.reload
    evaluation_recente.reload

    expect(ancienne_evaluation.anonymise_le).not_to be_nil
    expect(evaluation_recente.anonymise_le).to be_nil
    expect(evaluation_deja_anonymise.nom).to eq 'deja anonymise'
  end
end
