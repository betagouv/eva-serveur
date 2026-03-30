require 'rails_helper'

describe OpcoParcoursType, type: :model do
  subject(:opco_parcours_type) { build(:opco_parcours_type) }

  it { is_expected.to belong_to(:opco) }
  it { is_expected.to belong_to(:parcours_type) }

  context "quand l'association existe déjà" do
    let!(:opco) { create(:opco) }
    let!(:parcours_type) { create(:parcours_type) }
    let!(:opco_parcours_type) do
        create(:opco_parcours_type, opco: opco, parcours_type: parcours_type)
    end

    it "retourne un message explicite quand l'association existe déjà" do
      doublon = build(:opco_parcours_type, opco: opco, parcours_type: parcours_type)

      expect(doublon).not_to be_valid
      expect(doublon.errors[:parcours_type_id]).to include(
        I18n.t("activerecord.errors.models.opco_parcours_type.attributes.parcours_type_id.deja_associe_a_cet_opco")
      )
    end

    it "autorise le même parcours type pour un autre OPCO" do
      autre_opco = create(:opco)
      relation = build(:opco_parcours_type, opco: autre_opco, parcours_type: parcours_type)

      expect(relation).to be_valid
    end
  end
end
