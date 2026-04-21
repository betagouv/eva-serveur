require "rails_helper"

RSpec.describe StructureAdministrative, type: :model do
  describe "validations usage/opco" do
    it "est invalide sans usage" do
      structure = build(:structure_administrative, usage: nil)

      expect(structure).not_to be_valid
      expect(structure.errors[:usage]).to be_present
    end

    it "est invalide avec un usage hors liste" do
      structure = build(:structure_administrative, usage: "AUTRE_USAGE")

      expect(structure).not_to be_valid
      expect(structure.errors[:usage]).to be_present
    end

    it "requiert un opco en usage EVAPRO" do
      structure = build(:structure_administrative, usage: AvecUsage::USAGE_EVAPRO, opco: nil)

      expect(structure).not_to be_valid
      expect(structure.errors[:opco]).to be_present
    end

    it "accepte EVAPRO quand un opco est présent" do
      structure = build(:structure_administrative, usage: AvecUsage::USAGE_EVAPRO,
opco: create(:opco))

      expect(structure).to be_valid
    end
  end
end
