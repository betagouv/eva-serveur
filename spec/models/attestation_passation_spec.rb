require "rails_helper"

describe AttestationPassation do
  describe "#disponible?" do
    subject(:attestation) { described_class.new(evaluation) }

    let(:evaluation) { build(:evaluation, :evapro, completude: completude) }

    context "quand le questionnaire est complet" do
      let(:completude) { :complete }

      it { expect(attestation.disponible?).to be(true) }
    end

    context "quand le questionnaire est incomplet" do
      let(:completude) { :incomplete }

      it { expect(attestation.disponible?).to be(false) }
    end
  end
end
