require 'rails_helper'

describe LieurBeneficiaires, type: :model do
  describe '.call' do
    let(:beneficiaire) { instance_double(Beneficiaire, id: 1) }
    let(:beneficiaires) { class_double(Beneficiaire) }
    let(:evaluation) { class_double(Evaluation) }

    before do
      allow(Evaluation).to receive(:includes).with(:campagne).and_return(Evaluation)
      allow(Evaluation).to receive(:pour_beneficiaires).with([ 2,
        3 ]).and_return(evaluation)
      allow(evaluation).to receive(:update_all).with(beneficiaire_id: 1)
      allow(beneficiaires).to receive(:pluck).with(:id).and_return([ 2, 3 ])
      allow(beneficiaires).to receive(:destroy_all)
    end

    it do
      described_class.new(beneficiaire, beneficiaires).call

      expect(evaluation).to have_received(:update_all).with(beneficiaire_id: 1)
      expect(beneficiaires).to have_received(:destroy_all)
    end
  end
end
