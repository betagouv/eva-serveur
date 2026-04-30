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

      it "autorise la lecture des comptes de sa structure uniquement" do
        expect(ability.can?(:read, ActiveAdmin::Page, name: "Dashboard",
namespace_name: "admin")).to be(true)
        expect(ability.can?(:read, ActiveAdmin::Page, name: "Aide",
namespace_name: "admin")).to be(true)
        expect(ability.can?(:read, Actualite)).to be(true)
        expect(ability.can?(:read, compte)).to be(true)
        expect(ability.can?(:update, compte)).to be(true)
        expect(ability.can?(:read, structure_opco)).to be(true)

        autre_structure_meme_opco = create(
          :structure_locale,
          :avec_admin,
          usage: AvecUsage::USAGE_EVAPRO,
          opco: opco
        )
        compte_meme_opco = create(:compte_conseiller, :acceptee,
structure: autre_structure_meme_opco)
        structure_hors_opco = create(:structure_locale, :avec_admin)
        compte_hors_opco = create(:compte_conseiller, :acceptee, structure: structure_hors_opco)

        compte_meme_structure = create(:compte_conseiller, :acceptee, structure: structure_opco)

        expect(ability.can?(:read, compte_meme_structure)).to be(true)
        expect(ability.can?(:read, compte_meme_opco)).to be(false)
        expect(ability.can?(:read, compte_hors_opco)).to be(false)
        expect(ability.can?(:envoyer_invitation, compte_meme_opco.structure)).to be(false)
        expect(ability.can?(:envoyer_invitation, structure_opco)).to be(true)
        expect(ability.can?(:read, Evaluation)).to be(false)
        expect(ability.can?(:read, Campagne)).to be(false)
        expect(ability.can?(:read, Beneficiaire)).to be(false)
      end
    end

    context "avec un compte OPCO admin" do
      let(:compte) { create(:compte_admin, :acceptee, structure: structure_opco) }

      it "autorise la lecture des comptes de sa structure et de ses structures filles, " \
         "et refuse les autres" do
        structure_fille = create(
          :structure_locale,
          :avec_admin,
          usage: AvecUsage::USAGE_EVAPRO,
          opco: opco,
          structure_referente: structure_opco
        )
        compte_structure_fille = create(:compte_conseiller, :acceptee, structure: structure_fille)
        autre_structure_meme_opco = create(
          :structure_administrative,
          :avec_admin,
          usage: AvecUsage::USAGE_EVAPRO,
          opco: opco
        )
        compte_meme_opco = create(:compte_conseiller, :acceptee,
structure: autre_structure_meme_opco)
        structure_hors_opco = create(:structure_locale, :avec_admin)
        compte_hors_opco = create(:compte_conseiller, :acceptee, structure: structure_hors_opco)

        compte_meme_structure = create(:compte_conseiller, :acceptee, structure: structure_opco)

        expect(ability.can?(:read, compte_meme_structure)).to be(true)
        expect(ability.can?(:read, compte_structure_fille)).to be(true)
        expect(ability.can?(:read, compte_meme_opco)).to be(false)
        expect(ability.can?(:read, compte_hors_opco)).to be(false)
        expect(ability.can?(:envoyer_invitation, structure_fille)).to be(true)
        expect(ability.can?(:copier_lien, structure_fille)).to be(true)
        expect(ability.can?(:envoyer_invitation, autre_structure_meme_opco)).to be(false)
      end
    end
  end
end
