require "rails_helper"

RSpec.describe VerificateurSiret, type: :model do
  describe "#verifie_et_met_a_jour" do
    let(:structure) { build(:structure, siret: "12345678901234") }
    let(:client_sirene) { instance_double(Sirene::Client) }
    let(:verificateur) { described_class.new(structure) }

    before do
      allow(Sirene::Client).to receive(:new).and_return(client_sirene)
    end

    context "quand le SIRET est valide" do
      before do
        allow(client_sirene).to receive(:verifie_siret).with("12345678901234").and_return(true)
      end

      it "met à jour le statut SIRET à 'vérifié'" do
        verificateur.verifie_et_met_a_jour
        expect(structure.statut_siret).to eq("vérifié")
      end

      it "met à jour la date de vérification" do
        freeze_time = Time.zone.parse("2024-01-15 10:00:00")
        travel_to freeze_time do
          verificateur.verifie_et_met_a_jour
          expect(structure.date_verification_siret).to eq(freeze_time)
        end
      end

      it "retourne true" do
        expect(verificateur.verifie_et_met_a_jour).to be true
      end
    end

    context "quand le SIRET est invalide" do
      before do
        allow(client_sirene).to receive(:verifie_siret).with("12345678901234").and_return(false)
      end

      it "ne met pas à jour le statut SIRET" do
        verificateur.verifie_et_met_a_jour
        expect(structure.statut_siret).to be_nil
      end

      it "ne met pas à jour la date de vérification" do
        verificateur.verifie_et_met_a_jour
        expect(structure.date_verification_siret).to be_nil
      end

      it "retourne false" do
        expect(verificateur.verifie_et_met_a_jour).to be false
      end
    end

    context "quand le SIRET est vide" do
      let(:structure) { build(:structure, siret: nil) }

      it "retourne false sans appeler l'API" do
        expect(client_sirene).not_to receive(:verifie_siret)
        expect(verificateur.verifie_et_met_a_jour).to be false
      end
    end
  end
end

