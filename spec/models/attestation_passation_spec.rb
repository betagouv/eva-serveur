require "rails_helper"

describe AttestationPassation do
  describe ".active?" do
    before { allow(ENV).to receive(:[]).and_call_original }

    it "est active quand la variable d'environnement est définie" do
      allow(ENV).to receive(:[]).with("ACTIVE_ATTESTATION_PASSATION_EVAPRO").and_return("true")

      expect(described_class.active?).to be(true)
    end

    it "est inactive quand la variable d'environnement est absente" do
      allow(ENV).to receive(:[]).with("ACTIVE_ATTESTATION_PASSATION_EVAPRO").and_return(nil)

      expect(described_class.active?).to be(false)
    end
  end

  describe "#disponible?" do
    subject(:attestation) { described_class.new(evaluation) }

    let(:evaluation) { build(:evaluation, :evapro, completude: completude) }

    context "quand la fonctionnalité est active" do
      before { allow(described_class).to receive(:active?).and_return(true) }

      context "quand le questionnaire est complet" do
        let(:completude) { :complete }

        it { expect(attestation.disponible?).to be(true) }
      end

      context "quand le questionnaire est incomplet" do
        let(:completude) { :incomplete }

        it { expect(attestation.disponible?).to be(false) }
      end
    end

    context "quand la fonctionnalité est inactive" do
      let(:completude) { :complete }

      before { allow(described_class).to receive(:active?).and_return(false) }

      it { expect(attestation.disponible?).to be(false) }
    end
  end
end
