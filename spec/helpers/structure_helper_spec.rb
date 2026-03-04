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
end
