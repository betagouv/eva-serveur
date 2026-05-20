require 'rails_helper'

describe StatistiquesStructureMetabaseComponent, type: :component do
  let(:structure) { create :structure_opco }

  context "quand METABASE_SECRET_KEY est configurée" do
    before do
      allow(structure).to receive_messages(metabase_dashboard: 61,
        metabase_query_params: { "opco_id" => [ 42 ] })
      allow(ENV).to receive(:fetch).with("METABASE_SECRET_KEY", nil).and_return("secret")
      allow(ENV).to receive(:fetch).with("METABASE_SITE_URL", nil).and_return("http://metabase.example")
    end

    it "construit une url embed signée et filtrée sur l'opco" do
      component = described_class.new(structure: structure)

      url = component.url
      token = url.match(%r{/embed/dashboard/([^#]+)})[1]
      payload = JWT.decode(token, "secret", true, algorithm: "HS256").first

      expect(url).to start_with("http://metabase.example/embed/dashboard/")
      expect(url).to end_with("#bordered=false&titled=false")
      expect(payload["resource"]).to eq("dashboard" => 61)
      expect(payload["params"]).to eq("opco_id" => [ 42 ])
      expect(payload["exp"]).to be_within(5).of(10.minutes.from_now.to_i)
    end

    it "affiche l'iframe" do
      render_inline(described_class.new(structure: structure))

      expect(page).to have_css("iframe")
    end
  end

  context "quand METABASE_SECRET_KEY n'est pas configurée" do
    it "n'affiche pas d'iframe" do
      render_inline(described_class.new(structure: structure))

      expect(page).not_to have_css("iframe")
    end
  end
end
