require "rails_helper"

describe FabriqueStructure, type: :model do
  describe ".cree_depuis_siret" do
    let(:siret) { "12345678901234" }
    let(:structure_temporaire) do
      build(:structure_locale, siret: siret, code_postal: "75012", nom: "Test Structure")
    end

    before do
      allow(RechercheStructureParSiret).to receive(:new).with(siret).and_return(
        instance_double(RechercheStructureParSiret, call: structure_temporaire)
      )
    end


    context "quand le type_structure n'est pas entreprise" do
      let(:attributs_structure) { { type_structure: "mission_locale", usage: nil } }

      it "ne modifie pas l'usage" do
        structure = described_class.cree_depuis_siret(siret, attributs_structure)

        expect(structure.usage).to be_nil
        expect(structure.type_structure).to eq("mission_locale")
      end
    end

    context "quand RechercheStructureParSiret retourne nil" do
      before do
        allow(RechercheStructureParSiret).to receive(:new).with(siret).and_return(
          instance_double(RechercheStructureParSiret, call: nil)
        )
      end

      it "retourne nil" do
        structure = described_class.cree_depuis_siret(siret, {})

        expect(structure).to be_nil
      end
    end
  end
end
