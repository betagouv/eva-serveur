# frozen_string_literal: true

require 'rails_helper'

describe PersisteMetriquesPartieJob, type: :job do
  let(:evaluation) { create :evaluation }
  let(:partie) { create :partie, evaluation: evaluation }
  let(:restitution) { double }

  it "persiste les événéments d'une partie" do
    expect(FabriqueRestitution).to receive(:instancie).with(partie).and_return restitution
    expect(restitution).to receive(:persiste)
    expect { PersisteMetriquesPartieJob.perform_now(partie) }
      .to have_enqueued_job(PersisteRestitutionJob).exactly(1)
  end
end
