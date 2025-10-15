require "rails_helper"
require "cancan/matchers"

describe AbilityUtilisateur do
  subject(:ability) { described_class.new(compte) }

  let(:structure) { create(:structure_locale, :avec_admin) }
  let(:compte) { create(:compte, role: :admin, structure: structure) }


  describe "#can_update_active_pour_campagne?" do
    let(:campagne) { create(:campagne) }

    context "quand le compte est au moins admin" do
      it do
        expect(ability).to be_can_update_active_pour_campagne(campagne)
      end
    end

    context "quand le compte est le propriétaire de la campagne" do
      let(:compte) { create(:compte, role: :conseiller, structure: structure) }
      let(:campagne) { create(:campagne, compte: compte) }

      it do
        expect(ability).to be_can_update_active_pour_campagne(campagne)
      end
    end

    context "quand le compte n'est ni propriétaire, ni admin" do
      let(:compte) { create(:compte, role: :conseiller, structure: structure) }

      it do
        expect(ability).not_to be_can_update_active_pour_campagne(campagne)
      end
    end
  end

  describe "campagnes_de_la_structure" do
    context "quand le compte admin a une structure avec des structures filles" do
      subject(:autorisations_admin_administratif) { described_class.new(compte_admin) }

      let(:structure_administrative) { create(:structure_administrative) }
      let(:compte_admin) { create(:compte, role: :admin, structure: structure_administrative) }

      let(:structure_fille) {
 create(:structure_locale, structure_referente: structure_administrative) }
      let(:compte_structure_fille) { create(:compte, structure: structure_fille) }

      let(:campagne_parent) { create(:campagne, compte: compte_admin) }
      let(:campagne_fille) { create(:campagne, compte: compte_structure_fille) }


      before do
        # Force la création de la structure fille avant tous les tests
        structure_fille
      end

      it "vérifie que la hiérarchie est bien créée" do
        expect(structure_administrative.children).to include(structure_fille)
        expect(structure_administrative.subtree_ids).to include(structure_fille.id)
      end

      it "peut lire les campagnes de sa structure" do
        expect(autorisations_admin_administratif).to be_able_to(:read, campagne_parent)
      end

      it "peut lire les campagnes des structures filles" do
        expect(autorisations_admin_administratif).to be_able_to(:read, campagne_fille)
      end

      it "peut modifier les campagnes des structures filles" do
        expect(autorisations_admin_administratif).to be_able_to(:update, campagne_fille)
      end
    end
  end
end
