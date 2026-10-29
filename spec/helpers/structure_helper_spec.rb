require "rails_helper"

describe StructureHelper do
  describe "#structure_necessite_saisie_code_postal?" do
    context "quand la structure est une StructureLocale avec code_postal manquant" do
      let(:structure) { StructureLocale.new(code_postal: nil) }

      it "retourne true" do
        expect(helper.structure_necessite_saisie_code_postal?(structure)).to be(true)
      end
    end

    context "quand la structure est une StructureLocale avec code_postal TYPE_NON_COMMUNIQUE" do
      let(:structure) { StructureLocale.new(code_postal: StructureLocale::TYPE_NON_COMMUNIQUE) }

      it "retourne true" do
        expect(helper.structure_necessite_saisie_code_postal?(structure)).to be(true)
      end
    end

    context "quand la structure est une StructureLocale avec un code postal valide" do
      let(:structure) { StructureLocale.new(code_postal: "75012") }

      it "retourne false" do
        expect(helper.structure_necessite_saisie_code_postal?(structure)).to be(false)
      end
    end

    context "quand la structure n'est pas une StructureLocale" do
      let(:structure) { build(:structure_administrative) }

      it "retourne false" do
        expect(helper.structure_necessite_saisie_code_postal?(structure)).to be(false)
      end
    end
  end

  describe "#collection_usages" do
    it "associe chaque usage à sa traduction" do
      expect(helper.collection_usages).to eq(
        [
          [ I18n.t("activerecord.attributes.structure.usage.eva"), "eva" ],
          [ I18n.t("activerecord.attributes.structure.usage.evapro"), "evapro" ]
        ]
      )
    end
  end

  describe "#classe_badge_usage" do
    it "met Eva en bleu et laisse Evapro dans le gris par défaut des badges" do
      expect(helper.classe_badge_usage(AvecUsage::USAGE_EVA)).to eq("fr-badge--blue-cumulus")
      expect(helper.classe_badge_usage(AvecUsage::USAGE_EVAPRO)).to be_nil
    end
  end

  describe "#siret_requis?" do
    let(:ability_admin) { Ability.new(create(:compte_admin)) }
    let(:ability_superadmin) { Ability.new(create(:compte_superadmin)) }

    context "nouvelle structure" do
      let(:structure) { StructureLocale.new }

      it "retourne true pour un admin" do
        expect(helper.siret_requis?(structure, ability_admin)).to be(true)
      end

      it "retourne false pour un superadmin" do
        expect(helper.siret_requis?(structure, ability_superadmin)).to be(false)
      end
    end

    context "structure existante avec un siret" do
      let(:structure) { build_stubbed(:structure_locale, siret: '12345678901234') }

      it "retourne true pour un admin" do
        expect(helper.siret_requis?(structure, ability_admin)).to be(true)
      end

      it "retourne false pour un superadmin" do
        expect(helper.siret_requis?(structure, ability_superadmin)).to be(false)
      end
    end

    context "structure existante sans siret" do
      let(:structure) { build_stubbed(:structure_locale, siret: nil) }

      it "retourne false pour un admin" do
        expect(helper.siret_requis?(structure, ability_admin)).to be(false)
      end
    end
  end
end
