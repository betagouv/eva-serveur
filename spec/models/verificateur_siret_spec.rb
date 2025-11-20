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
      let(:donnees_etablissement) { { code_naf: "16.10A", idcc: "8432" } }

      before do
        allow(client_sirene).to receive(:verifie_siret).with("12345678901234").and_return(true)
        allow(client_sirene).to receive(:recupere_donnees_etablissement)
          .with("12345678901234")
          .and_return(donnees_etablissement)
      end

      it "met à jour le statut SIRET à true" do
        verificateur.verifie_et_met_a_jour
        expect(structure.statut_siret).to be true
      end

      it "met à jour la date de vérification" do
        freeze_time = Time.zone.parse("2024-01-15 10:00:00")
        Timecop.freeze(freeze_time) do
          verificateur.verifie_et_met_a_jour
          expect(structure.date_verification_siret).to eq(freeze_time)
        end
      end

      it "récupère et stocke le code NAF" do
        verificateur.verifie_et_met_a_jour
        expect(structure.code_naf).to eq("16.10A")
      end

      it "récupère et stocke l'IDCC" do
        verificateur.verifie_et_met_a_jour
        expect(structure.idcc).to eq("8432")
      end

      it "retourne true" do
        expect(verificateur.verifie_et_met_a_jour).to be true
      end
    end

    context "quand le code NAF est manquant" do
      let(:donnees_etablissement) { { code_naf: nil, idcc: "8432" } }

      before do
        allow(client_sirene).to receive(:verifie_siret).with("12345678901234").and_return(true)
        allow(client_sirene).to receive(:recupere_donnees_etablissement)
          .with("12345678901234")
          .and_return(donnees_etablissement)
      end

      it "lève une erreur" do
        expect { verificateur.verifie_et_met_a_jour }
          .to raise_error(/Données incomplètes de l'API SIRENE/)
      end
    end

    context "quand l'IDCC est manquant" do
      let(:donnees_etablissement) { { code_naf: "16.10A", idcc: nil } }

      before do
        allow(client_sirene).to receive(:verifie_siret).with("12345678901234").and_return(true)
        allow(client_sirene).to receive(:recupere_donnees_etablissement)
          .with("12345678901234")
          .and_return(donnees_etablissement)
      end

      it "lève une erreur" do
        expect { verificateur.verifie_et_met_a_jour }
          .to raise_error(/Données incomplètes de l'API SIRENE/)
      end
    end

    context "quand les données de l'établissement ne peuvent pas être récupérées" do
      before do
        allow(client_sirene).to receive(:verifie_siret).with("12345678901234").and_return(true)
        allow(client_sirene).to receive(:recupere_donnees_etablissement)
          .with("12345678901234")
          .and_return(nil)
      end

      it "lève une erreur" do
        expect { verificateur.verifie_et_met_a_jour }
          .to raise_error(/Impossible de récupérer les données de l'établissement/)
      end
    end

    context "quand le SIRET est invalide" do
      before do
        allow(client_sirene).to receive(:verifie_siret).with("12345678901234").and_return(false)
      end

      it "ne met pas à jour le statut SIRET" do
        verificateur.verifie_et_met_a_jour
        expect(structure.statut_siret).to be false
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
