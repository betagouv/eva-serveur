# frozen_string_literal: true

require 'rails_helper'

describe PersisteRestitutionJob, type: :job do
  let(:evaluation) { create :evaluation }
  let(:restitution) { double }

  it "persiste la restitution des compétences de base d'une partie" do
    expect(FabriqueRestitution).to receive(:restitution_globale)
      .with(evaluation)
      .and_return restitution
    expect(restitution).to receive(:persiste)
    described_class.perform_now(evaluation)
  end
end
