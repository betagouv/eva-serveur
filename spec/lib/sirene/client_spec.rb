require "rails_helper"

RSpec.describe Sirene::Client, type: :lib do
  describe "#verifie_siret" do
    let(:siret) { "12345678901234" }
    let(:client) { described_class.new }
    let(:url) { "https://api.insee.fr/entreprises/sirene/V3.11/siret/#{siret}" }

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
        allow(tr).to receive(:success?).and_return(true)
        allow(tr).to receive(:body).and_return(reponse_api.to_json)
        expect(Typhoeus).to receive(:get).with(url, hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))).and_return(tr)
      end

      it "retourne true" do
        expect(client.verifie_siret(siret)).to be true
      end
    end

    context "quand le SIRET n'est pas trouvé dans l'API SIRENE" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive(:success?).and_return(false)
        allow(tr).to receive(:code).and_return(404)
        allow(tr).to receive(:body).and_return({ "header" => { "statut" => 404, "message" => "Aucun établissement trouvé" } }.to_json)
        expect(Typhoeus).to receive(:get).with(url, hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))).and_return(tr)
      end

      it "retourne false" do
        expect(client.verifie_siret(siret)).to be false
      end
    end

    context "quand l'API retourne une erreur serveur" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive(:success?).and_return(false)
        allow(tr).to receive(:code).and_return(500)
        allow(tr).to receive(:body).and_return("Internal Server Error")
        expect(Typhoeus).to receive(:get).with(url, hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))).and_return(tr)
      end

      it "retourne false" do
        expect(client.verifie_siret(siret)).to be false
      end
    end

    context "quand l'API timeout" do
      before do
        tr = Typhoeus::Response.new
        allow(tr).to receive(:success?).and_return(false)
        allow(tr).to receive(:timed_out?).and_return(true)
        expect(Typhoeus).to receive(:get).with(url, hash_including(headers: hash_including("Authorization" => match(/^Bearer /)))).and_return(tr)
      end

      it "retourne false" do
        expect(client.verifie_siret(siret)).to be false
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

