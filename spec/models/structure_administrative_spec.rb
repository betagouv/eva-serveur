require "rails_helper"

RSpec.describe StructureAdministrative, type: :model do
  describe "#structures_locales_filles" do
    let(:structure) { create(:structure_administrative) }

    it "retourne les enfants de type StructureLocale" do
      structure_locale = create(:structure_locale, parent: structure)

      expect(structure.structures_locales_filles).to contain_exactly(structure_locale)
    end

    it "exclut les enfants qui ne sont pas des StructureLocale" do
      create(:structure_administrative, parent: structure)

      expect(structure.structures_locales_filles).to be_empty
    end

    it "retourne une collection vide si aucun enfant" do
      expect(structure.structures_locales_filles).to be_empty
    end
  end

  describe "#metabase_query_params" do
    let(:structure) { create(:structure_administrative) }

    it "retourne un hash avec les ids des structures locales filles" do
      structure_locale = create(:structure_locale, parent: structure)

      expect(structure.metabase_query_params).to eq({ "structures" => [ structure_locale.id ] })
    end

    it "retourne un hash avec une liste vide si aucune structure locale fille" do
      create(:structure_administrative, parent: structure)

      expect(structure.metabase_query_params).to eq({ "structures" => [] })
    end
  end
end
