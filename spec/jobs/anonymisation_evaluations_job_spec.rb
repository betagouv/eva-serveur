# frozen_string_literal: true

require 'rails_helper'

describe AnonymisationEvaluationsJob, type: :job do
  it "anonymise les évaluations de plus d'un an" do
    Timecop.freeze(Time.zone.local(2025, 1, 2, 12, 0, 0)) do
      ancienne_evaluation = create :evaluation, nom: 'nom original',
                                                created_at: Date.new(2020, 1, 2)
      evaluation_recente = create :evaluation, nom: 'nom original', created_at: Date.new(2020, 1, 3)
      evaluation_deja_anonymise = create :evaluation, anonymise_le: Date.new(2025, 1, 1),
                                                      created_at: Date.new(2020, 1, 1),
                                                      nom: 'deja anonymise'

      described_class.perform_now

      ancienne_evaluation.reload
      evaluation_recente.reload
      evaluation_deja_anonymise.reload

      expect(ancienne_evaluation.anonymise_le).to eq Time.zone.local(2025, 1, 2, 12, 0, 0)
      expect(ancienne_evaluation.nom).not_to eq 'nom original'
      expect(evaluation_recente.anonymise_le).to be_nil
      expect(evaluation_recente.nom).to eq 'nom original'
      expect(evaluation_deja_anonymise.nom).to eq 'deja anonymise'
    end
  end
end
