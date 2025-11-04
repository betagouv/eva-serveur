require 'rails_helper'

describe LanceurCampagne do
  let(:parcours_type) { instance_double(ParcoursType, diagnostic_entreprise?: false) }
  let(:campagne) { instance_double(Campagne, code: "1234", parcours_type: parcours_type) }
  let(:compte) { nil }
  let(:lanceur_campagne) { described_class.new(campagne, compte) }

  describe "#url" do
    it "retourne l'URL correcte pour une campagne standard" do
      expect(lanceur_campagne.url).to eq("#{URL_CLIENT}?code=#{campagne.code}")
    end

    context "lorsque parcours_type est diagnostic_entreprise" do
      let(:parcours_type) { instance_double(ParcoursType, diagnostic_entreprise?: true) }
      let(:compte) { instance_double(Compte, nom_complet: "Jean Dupont") }

      context "quand le compte n'a pas de bénéficiaire" do
        it "retourne l'URL correcte pour une campagne d'entreprise avec bénéficiaire_id" do
          url = "#{URL_EVA_ENTREPRISES}?code=#{campagne.code}&beneficiaire_id="
          expect(lanceur_campagne.url).to start_with(url)
        end
      end

      context "quand le compte a un bénéficiaire" do
        let(:compte) { create(:compte) }
        let!(:beneficiaire) { create(:beneficiaire, compte: compte) }

        it "retourne l'URL correcte pour une campagne d'entreprise avec bénéficiaire_id" do
          url = "#{URL_EVA_ENTREPRISES}?code=#{campagne.code}&beneficiaire_id=#{beneficiaire.id}"
          expect(lanceur_campagne.url).to eq(url)
        end
      end
    end
  end

  describe ".url" do
    it "délégue à la méthode d'instance" do
      expect(described_class.url(campagne)).to eq(lanceur_campagne.url)
    end
  end
end
