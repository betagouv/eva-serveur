require "rails_helper"

RSpec.describe Sirene::Client, type: :lib do
  describe "#verifie_siret" do
    let(:siret) { "12345678901234" }
    let(:client) { described_class.new }
    let(:url) { "https://api.insee.fr/entreprises/sirene/V3.11/siret/#{siret}" }

    before do
      # Réinitialise les mocks globaux pour ces tests
      RSpec::Mocks.space.proxy_for(Typhoeus).reset
      RSpec::Mocks.space.proxy_for(described_class).reset
    end

    context "quand le SIRET est trouvé dans l'API SIRENE" do
      let(:reponse_api) do
        {
          "etablissement" => {
            "siret" => siret,
            "uniteLegale" => {
              "denominationUniteLegale" => "Entreprise Test"
            }
          }
        }
      end

      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: true, body: reponse_api.to_json)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))
        ).and_return(tr)
      end

      it "retourne true" do
        expect(client.verifie_siret(siret)).to be true
        expect(Typhoeus).to have_received(:get)
      end
    end

    context "quand le SIRET n'est pas trouvé dans l'API SIRENE" do
      let(:reponse_erreur) do
        { "header" => { "statut" => 404, "message" => "Aucun établissement trouvé" } }
      end

      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: false, code: 404, body: reponse_erreur.to_json)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))
        ).and_return(tr)
      end

      it "retourne false" do
        expect(client.verifie_siret(siret)).to be false
        expect(Typhoeus).to have_received(:get)
      end
    end

    context "quand l'API retourne une erreur serveur" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: false, code: 500, body: "Internal Server Error")
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))
        ).and_return(tr)
      end

      it "retourne false" do
        expect(client.verifie_siret(siret)).to be false
        expect(Typhoeus).to have_received(:get)
      end
    end

    context "quand l'API timeout" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: false, timed_out?: true)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))
        ).and_return(tr)
      end

      it "retourne false" do
        expect(client.verifie_siret(siret)).to be false
        expect(Typhoeus).to have_received(:get)
      end
    end

    context "quand le SIRET est vide" do
      it "retourne false" do
        expect(client.verifie_siret("")).to be false
        expect(client.verifie_siret(nil)).to be false
      end
    end
  end

  describe "#recupere_donnees_etablissement" do
    let(:siret) { "12345678901234" }
    let(:client) { described_class.new }
    let(:url) { "https://api.insee.fr/entreprises/sirene/V3.11/siret/#{siret}" }

    before do
      # Réinitialise les mocks globaux pour ces tests
      RSpec::Mocks.space.proxy_for(Typhoeus).reset
      RSpec::Mocks.space.proxy_for(described_class).reset
    end

    context "quand les données sont récupérées avec succès" do
      let(:reponse_api) do
        {
          "etablissement" => {
            "siret" => siret,
            "periodesEtablissement" => [
              {
                "dateFin" => nil,
                "activitePrincipale" => "16.10A",
                "conventionCollective" => "IDCC 8432"
              }
            ]
          }
        }
      end

      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: true, body: reponse_api.to_json)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))
        ).and_return(tr)
      end

      it "retourne le code NAF et l'IDCC" do
        donnees = client.recupere_donnees_etablissement(siret)
        expect(donnees).to eq(code_naf: "16.10A", idcc: "8432")
      end
    end

    context "quand l'IDCC est au format numérique uniquement" do
      let(:reponse_api) do
        {
          "etablissement" => {
            "siret" => siret,
            "periodesEtablissement" => [
              {
                "dateFin" => nil,
                "activitePrincipale" => "16.10A",
                "conventionCollective" => "8432"
              }
            ]
          }
        }
      end

      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: true, body: reponse_api.to_json)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))
        ).and_return(tr)
      end

      it "extrait correctement l'IDCC" do
        donnees = client.recupere_donnees_etablissement(siret)
        expect(donnees[:idcc]).to eq("8432")
      end
    end

    context "quand l'établissement n'existe pas" do
      let(:reponse_erreur) do
        { "header" => { "statut" => 404, "message" => "Aucun établissement trouvé" } }
      end

      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: false, code: 404, body: reponse_erreur.to_json)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))
        ).and_return(tr)
      end

      it "retourne nil" do
        expect(client.recupere_donnees_etablissement(siret)).to be_nil
      end
    end

    context "quand le SIRET est vide" do
      it "retourne nil" do
        expect(client.recupere_donnees_etablissement("")).to be_nil
        expect(client.recupere_donnees_etablissement(nil)).to be_nil
      end
    end
  end
end
