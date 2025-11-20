require "rails_helper"

describe Sirene::Client, type: :lib do
  describe "#recherche" do
    let(:siret) { "35600000050439" }
    let(:client) { described_class.new }
    let(:api_url) { "https://recherche-entreprises.api.gouv.fr" }
    let(:url) { "#{api_url}/search?q=#{siret}" }

    before do
      # Stub la constante BASE_URL pour utiliser l'URL de test
      stub_const("Sirene::Client::BASE_URL", api_url)
      # Réinitialise les mocks globaux pour ces tests
      RSpec::Mocks.space.proxy_for(Typhoeus).reset
      RSpec::Mocks.space.proxy_for(described_class).reset
    end

    context "quand l'API retourne des résultats" do
      let(:reponse_api) do
        {
          "results" => [
            {
              "siren" => "356000000",
              "nom_complet" => "LA POSTE",
              "activite_principale" => "53.10Z",
              "siege" => {
                "siret" => "35600000000048"
              },
              "matching_etablissements" => [
                {
                  "siret" => siret,
                  "adresse" => "243 BOULEVARD JEAN JAURES 92100 BOULOGNE-BILLANCOURT"
                }
              ],
              "complements" => {
                "liste_idcc" => [ "5516", "9999" ]
              }
            }
          ],
          "total_results" => 1,
          "page" => 1,
          "per_page" => 10,
          "total_pages" => 1
        }
      end

      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: true, body: reponse_api.to_json)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Accept" => "application/json"))
        ).and_return(tr)
      end

      it "retourne les données brutes de l'API" do
        resultat = client.recherche(siret)
        expect(resultat).to eq(reponse_api)
        expect(Typhoeus).to have_received(:get)
      end
    end

    context "quand l'API ne retourne aucun résultat" do
      let(:reponse_api) do
        {
          "results" => [],
          "total_results" => 0,
          "page" => 1,
          "per_page" => 10,
          "total_pages" => 0
        }
      end

      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: true, body: reponse_api.to_json)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Accept" => "application/json"))
        ).and_return(tr)
      end

      it "retourne les données avec un tableau de résultats vide" do
        resultat = client.recherche(siret)
        expect(resultat["results"]).to eq([])
      end
    end

    context "quand l'API retourne une erreur serveur" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: false, code: 500, body: "Internal Server Error")
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Accept" => "application/json"))
        ).and_return(tr)
      end

      it "retourne nil" do
        expect(client.recherche(siret)).to be_nil
      end
    end

    context "quand l'API timeout" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: false, timed_out?: true)
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Accept" => "application/json"))
        ).and_return(tr)
      end

      it "retourne nil" do
        expect(client.recherche(siret)).to be_nil
      end
    end

    context "quand l'API retourne une erreur de parsing JSON" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive_messages(success?: true, body: "invalid json")
        allow(Typhoeus).to receive(:get).with(
          url,
          hash_including(headers: hash_including("Accept" => "application/json"))
        ).and_return(tr)
      end

      it "retourne nil et log l'erreur" do
        expect(Rails.logger).to receive(:error).with(/Erreur lors de la recherche SIRET/)
        expect(client.recherche(siret)).to be_nil
      end
    end

    context "quand le SIRET est vide" do
      it "retourne nil sans appeler l'API" do
        expect(Typhoeus).not_to receive(:get)
        expect(client.recherche("")).to be_nil
        expect(client.recherche(nil)).to be_nil
      end
    end
  end
end
