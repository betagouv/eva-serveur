require "rails_helper"

RSpec.describe CreationCompteDepuisInvitationService do
  describe "#appeler" do
    it "n'exige pas de SIRET pro connect dans le parcours invitation" do
      structure = create(:structure_locale).tap { |s| s.update_column(:siret, nil) }
      invitant = create(:compte_admin, :acceptee, structure: structure)
      invitation = create(:invitation, structure: structure, invitant: invitant, role: "conseiller")
      params = {
        email: "invite-opco@eva.fr",
        password: "Password78901$",
        password_confirmation: "Password78901$",
        nom: "Invite",
        prenom: "OPCO",
        cgu_acceptees: true
      }

      result = described_class.new(invitation: invitation, parametres_compte: params).appeler

      expect(result.succes).to be(true)
      expect(result.compte).to be_persisted
      expect(result.compte.structure).to eq(structure)
      expect(result.compte.siret).to be_nil
    end
  end
end
