require "rails_helper"

describe ActualiteHelper do
  describe "#classe_badge_categorie_actualite" do
    it "associe chaque catégorie à une couleur de badge" do
      expect(helper.classe_badge_categorie_actualite("assistance")).to eq("fr-badge--pink-macaron")
      expect(helper.classe_badge_categorie_actualite("blog"))
        .to eq("fr-badge--yellow-tournesol")
      expect(helper.classe_badge_categorie_actualite("evolution")).to eq("fr-badge--green-emeraude")
    end
  end
end
