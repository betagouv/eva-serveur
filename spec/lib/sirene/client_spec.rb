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
end
