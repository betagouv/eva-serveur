require "rails_helper"

RSpec.describe EnvoiInvitationService do
  describe "#call" do
    let(:structure_invitant) { create(:structure_locale, :avec_admin) }
    let(:structure_autre) { create(:structure_locale, :avec_admin) }
    let(:invitant) { create(:compte_conseiller, :acceptee, structure: structure_invitant) }

    it "autorise une invitation sur la structure du conseiller" do
      result = described_class.new(
        structure: structure_invitant,
        invitant: invitant,
        email: "invite@eva.fr"
      ).call

      expect(result.success?).to be(true)
      expect(result.invitation).to be_present
      expect(result.invitation.structure).to eq(structure_invitant)
    end

    it "refuse une invitation hors de la structure du conseiller" do
      result = described_class.new(
        structure: structure_autre,
        invitant: invitant,
        email: "invite@eva.fr"
      ).call

      expect(result.success?).to be(false)
      expect(result.error).to eq(:invitation_non_autorisee)
    end
  end
end
