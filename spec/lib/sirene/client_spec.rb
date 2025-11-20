require "rails_helper"

describe Sirene::Client, type: :lib do
  describe "#verifie_siret" do
    let(:siret) { "35600000050439" }
    let(:client) { described_class.new }
    let(:api_url) { ENV.fetch("SIRENE_API_URL") }
    let(:url) { "#{api_url}/search?q=#{siret}" }

    before do
      RSpec::Mocks.space.proxy_for(Typhoeus).reset
      RSpec::Mocks.space.proxy_for(described_class).reset
    end

    context "quand le SIRET est trouvé dans l'API (dans matching_etablissements)" do
      let(:reponse_api) do
        {
          "results" => [
            {
              "siren" => "356000000",
              "nom_complet" => "LA POSTE",
              "siege" => {
                "siret" => "35600000000048"
              },
              "matching_etablissements" => [
                {
                  "siret" => siret,
                  "adresse" => "243 BOULEVARD JEAN JAURES 92100 BOULOGNE-BILLANCOURT"
                }
              ]
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

      it "retourne true" do
        expect(client.verifie_siret(siret)).to be true
        expect(Typhoeus).to have_received(:get)
      end
    end

    context "quand le SIRET est trouvé dans l'API (dans siege)" do
      let(:reponse_api) do
        {
          "results" => [
            {
              "siren" => "356000000",
              "nom_complet" => "LA POSTE",
              "siege" => {
                "siret" => siret,
                "adresse" => "9 RUE DU COLONEL PIERRE AVIA 75015 PARIS"
              },
              "matching_etablissements" => []
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

      it "retourne true" do
        expect(client.verifie_siret(siret)).to be true
        expect(Typhoeus).to have_received(:get)
      end
    end

    context "quand le SIRET n'est pas trouvé dans l'API" do
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
          hash_including(headers: hash_including("Accept" => "application/json"))
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
          hash_including(headers: hash_including("Accept" => "application/json"))
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
end
