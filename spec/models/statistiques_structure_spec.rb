require 'rails_helper'

describe StatistiquesStructure do
  describe '#correlation_entre_niveau_illettrisme_et_genre' do
    let(:structure) { create :structure }
    let(:compte) { create :compte, structure: structure }
    let(:campagne) { create :campagne, compte: compte }

    let(:evaluation) do
      create :evaluation, campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel
    end
    let(:evaluation2) do
      create :evaluation, campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel
    end
    let(:evaluation_autre) do
      create :evaluation, synthese_competences_de_base: :illettrisme_potentiel
    end

    let(:resultat) do
      described_class.new(structure)
                     .correlation_entre_niveau_illettrisme_et_genre(:illettrisme_potentiel)
    end

    context "quand la structure n'a pas de données sociodémographiques" do
      it 'ne renvoie rien' do
        expect(resultat).to be_nil
      end
    end

    context 'quand la structure a des données sociodémographiques' do
      let!(:donnee_sociodemographique) do
        create :donnee_sociodemographique, genre: 'femme', evaluation: evaluation
      end
      let!(:donnee_sociodemographique2) do
        create :donnee_sociodemographique, genre: 'homme', evaluation: evaluation2
      end
      let!(:donnee_sociodemographique_autre) do
        create :donnee_sociodemographique, genre: 'homme', evaluation: evaluation_autre
      end

      it "renvoie le pourcentage d'un genre donné" do
        expect(resultat['femme']).to be(50.0)
        expect(resultat['homme']).to be(50.0)
      end

      it 'assigne zero aux genres sans évaluation' do
        expect(resultat['autre']).to be(0)
      end
    end
  end

  describe "#url" do
   let(:structure) { create :structure_opco }

    context "quand METABASE_SECRET_KEY est configurée" do
      before do
        allow(structure).to receive_messages(metabase_dashboard: 61,
          metabase_query_params: { "opco_id" => [ 42 ] })
        allow(ENV).to receive(:fetch).with("METABASE_SECRET_KEY", nil).and_return("secret")
        allow(ENV).to receive(:fetch).with("METABASE_SITE_URL", nil).and_return("http://metabase.example")
      end

      it "construit une url embed signée et filtrée sur l'opco" do
        statistiques_opco = described_class.new(structure)

        url = statistiques_opco.url
        token = url.match(%r{/embed/dashboard/([^#]+)})[1]
        payload = JWT.decode(token, "secret", true, algorithm: "HS256").first

        expect(url).to start_with("http://metabase.example/embed/dashboard/")
        expect(url).to end_with("#bordered=false&titled=false")
        expect(payload["resource"]).to eq("dashboard" => 61)
        expect(payload["params"]).to eq("opco_id" => [ 42 ])
        expect(payload["exp"]).to be_within(5).of(10.minutes.from_now.to_i)
      end
    end

    context "quand METABASE_SECRET_KEY n'est pas configurée" do
      it "retourne nil" do
        expect(described_class.new(structure).url).to be_nil
      end
    end
  end
end
