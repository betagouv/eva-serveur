require "rails_helper"

RSpec.describe StatistiquesOpco do
  describe "#url" do
    it "construit une url embed signée et filtrée sur l'opco" do
      statistiques_opco = described_class.new(
        opco_id: 42,
        dashboard_id: 61,
        metabase_site_url: "http://metabase.example",
        metabase_secret_key: "secret"
      )

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
end
