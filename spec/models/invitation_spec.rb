# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitation, type: :model do
  describe "validations" do
    it { is_expected.to validate_inclusion_of(:role).in_array(Invitation::ROLES) }
  end

  describe "role_pour_compte" do
    it "retourne le rôle de l'invitation quand il est présent" do
      invitation = build(:invitation, role: "admin")
      expect(invitation.role_pour_compte).to eq("admin")
    end

    it "retourne conseiller par défaut quand le rôle est vide (rétrocompatibilité)" do
      invitation = build(:invitation)
      allow(invitation).to receive(:role).and_return(nil)
      expect(invitation.role_pour_compte).to eq("conseiller")
    end
  end

  describe "création avec rôle par défaut" do
    it "persiste avec role conseiller par défaut" do
      invitation = create(:invitation, email_destinataire: "defaut@test.com")
      expect(invitation.reload.role).to eq("conseiller")
    end
  end
end
