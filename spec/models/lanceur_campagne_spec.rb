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

  describe "création du bénéficiaire" do
    let(:compte) { create(:compte) }

    context "quand la campagne est de type diagnostic_entreprise" do
      let(:parcours_type) { create(:parcours_type, type_de_programme: :diagnostic_entreprise) }
      let(:campagne) { create(:campagne, parcours_type: parcours_type) }

      it "crée un bénéficiaire lors de la génération de l'URL" do
        expect {
          described_class.url(campagne, compte)
        }.to change(Beneficiaire, :count).by(1)
      end

      it "associe le bénéficiaire au compte" do
        lanceur = described_class.url(campagne, compte)
        beneficiaire = Beneficiaire.find_by(compte: compte)
        expect(beneficiaire).to be_present
        expect(beneficiaire.nom).to eq(compte.nom_complet)
      end
    end

    context "quand la campagne n'est pas de type diagnostic_entreprise" do
      let(:parcours_type) { create(:parcours_type, type_de_programme: :diagnostic) }
      let(:campagne) { create(:campagne, parcours_type: parcours_type) }

      it "ne crée pas de bénéficiaire lors de la génération de l'URL" do
        expect {
          described_class.url(campagne, compte)
        }.not_to change(Beneficiaire, :count)
      end
    end

    context "quand aucun compte n'est fourni" do
      let(:compte) { nil }
      let(:parcours_type) { create(:parcours_type, type_de_programme: :diagnostic_entreprise) }
      let(:campagne) { create(:campagne, parcours_type: parcours_type) }

      it "ne crée pas de bénéficiaire" do
        expect {
          described_class.url(campagne, compte)
        }.not_to change(Beneficiaire, :count)
      end
    end

    context "quand la campagne n'a pas de parcours_type" do
      let(:campagne) { instance_double(Campagne, code: "1234", parcours_type: nil) }
      let(:compte) { create(:compte) }

      it "ne crée pas de bénéficiaire et ne provoque pas d'erreur" do
        expect {
          described_class.url(campagne, compte)
        }.not_to change(Beneficiaire, :count)
      end
    end
  end
end
