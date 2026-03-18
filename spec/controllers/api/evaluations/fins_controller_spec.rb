require 'rails_helper'

describe Api::Evaluations::FinsController do
  let(:compte) { create :compte_admin }
  let(:campagne) { create :campagne, compte: compte }
  let(:evaluation) { create :evaluation, campagne: campagne }

  describe '#create' do
    it 'enregistre terminee_le au bon format quand elle est iso' do
      terminee_le = Time.zone.local(2026, 3, 18, 14, 30, 0)

      post :create, params: { evaluation_id: evaluation.id, terminee_le: terminee_le.iso8601 }

      expect(evaluation.reload.terminee_le).to eq(terminee_le)
    end

    it "enregistre terminee_le dans la local du serveur si ce n'est pas précisé" do
      terminee_le = '2026-03-18T14:30:00'

      post :create, params: { evaluation_id: evaluation.id, terminee_le: terminee_le }

      expect(evaluation.reload.terminee_le).to eq(Time.zone.local(2026, 3, 18, 14, 30, 0))
    end

    it "enregistre terminee_le à maintenant quand il n'est pas passé (déprécié)" do
      now = Time.zone.now
      Timecop.freeze(now) do
        post :create, params: { evaluation_id: evaluation.id }

        expect(evaluation.reload.terminee_le).to be_within(1.second).of(now)
      end
    end
  end
end
