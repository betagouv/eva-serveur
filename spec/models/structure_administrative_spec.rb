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

  describe "nettoyage des champs selon l'usage" do
    it "supprime la structure référente quand l'usage passe en EVAPRO" do
      structure_referente = create(:structure_administrative)
      opco = create(:opco)
      structure = create(
        :structure_administrative,
        usage: AvecUsage::USAGE_BENEFICIAIRES,
        parent: structure_referente
      )

      structure.update!(usage: AvecUsage::USAGE_EVAPRO, opco: opco)

      expect(structure.reload.parent_id).to be_nil
      expect(structure.opco).to eq(opco)
    end

    it "supprime l'opco quand l'usage passe en Eva: bénéficiaires" do
      opco = create(:opco)
      structure_referente = create(:structure_administrative)
      structure = create(
        :structure_administrative,
        usage: AvecUsage::USAGE_EVAPRO,
        opco: opco
      )

      structure.update!(
        usage: AvecUsage::USAGE_BENEFICIAIRES,
        parent: structure_referente
      )

      expect(structure.reload.opco_id).to be_nil
      expect(structure.parent).to eq(structure_referente)
    end
  end
end
