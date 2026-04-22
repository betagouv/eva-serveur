require "rails_helper"

RSpec.describe Ability do
  subject(:ability) { described_class.new(compte) }

  let(:opco) { create(:opco) }
  let(:structure_opco) do
    create(:structure_administrative, :avec_admin, usage: AvecUsage::USAGE_EVAPRO, opco: opco)
  end

  describe "droits OPCO restreints" do
    context "avec un compte OPCO non admin" do
      let(:compte) { create(:compte_conseiller, :acceptee, structure: structure_opco) }

      it "autorise uniquement le périmètre OPCO attendu" do
        expect(ability.can?(:read, ActiveAdmin::Page, name: "Dashboard",
namespace_name: "admin")).to be(true)
        expect(ability.can?(:read, ActiveAdmin::Page, name: "Aide",
namespace_name: "admin")).to be(true)
        expect(ability.can?(:read, Actualite)).to be(true)
        expect(ability.can?(:read, compte)).to be(true)
        expect(ability.can?(:update, compte)).to be(true)
        expect(ability.can?(:read, structure_opco)).to be(true)

        autre_compte = create(:compte_conseiller, :acceptee, structure: structure_opco)
        expect(ability.can?(:read, autre_compte)).to be(false)
        expect(ability.can?(:read, Evaluation)).to be(false)
        expect(ability.can?(:read, Campagne)).to be(false)
        expect(ability.can?(:read, Beneficiaire)).to be(false)
      end
    end

    context "avec un compte OPCO admin" do
      let(:compte) { create(:compte_admin, :acceptee, structure: structure_opco) }

      it "autorise la lecture des comptes de son périmètre" do
        compte_meme_structure = create(:compte_conseiller, :acceptee, structure: structure_opco)
        structure_externe = create(:structure_locale, :avec_admin)
        compte_hors_perimetre = create(:compte_conseiller, :acceptee, structure: structure_externe)

        expect(ability.can?(:read, compte_meme_structure)).to be(true)
        expect(ability.can?(:read, compte_hors_perimetre)).to be(false)
      end
    end
  end
end
