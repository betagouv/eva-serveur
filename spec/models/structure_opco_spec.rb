require "rails_helper"

describe StructureOpco, type: :model do
  let(:structure) { create(:structure_locale) }
  let(:opco) { create(:opco) }
  let(:structure_opco) { build(:structure_opco, structure: structure, opco: opco) }

  describe "validations" do
    it { is_expected.to belong_to(:structure) }
    it { is_expected.to belong_to(:opco) }

    it "valide l'unicité de la combinaison structure_id et opco_id" do
      create(:structure_opco, structure: structure, opco: opco)

      duplicate = build(:structure_opco, structure: structure, opco: opco)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:structure_id]).to be_present
    end

    it "permet plusieurs OPCOs pour la même structure" do
      opco2 = create(:opco, nom: "OPCO 2")
      create(:structure_opco, structure: structure, opco: opco)
      structure_opco2 = build(:structure_opco, structure: structure, opco: opco2)

      expect(structure_opco2).to be_valid
    end

    it "permet le même OPCO pour plusieurs structures" do
      structure2 = create(:structure_locale, nom: "Structure 2")
      create(:structure_opco, structure: structure, opco: opco)
      structure_opco2 = build(:structure_opco, structure: structure2, opco: opco)

      expect(structure_opco2).to be_valid
    end
  end
end
