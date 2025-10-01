require 'rails_helper'

describe PersisteMetriquesPartieJob, type: :job do
  let(:evaluation) { create :evaluation }
  let(:partie) { create :partie, evaluation: evaluation }
  let(:restitution) { double }

  it "persiste les métriques d'une partie" do
    expect(FabriqueRestitution).to receive(:instancie).with(partie).and_return restitution
    expect(restitution).to receive(:persiste)
    expect { described_class.perform_now(partie) }
      .to have_enqueued_job(PersisteRestitutionJob).exactly(1)
  end
end
