class StatistiquesOpco
  def initialize(opco_id:, dashboard_id: ENV["METABASE_OPCO_DASHBOARD_ID"],
                 metabase_site_url: ENV["METABASE_SITE_URL"],
                 metabase_secret_key: ENV["METABASE_SECRET_KEY"])
    @opco_id = opco_id
    @dashboard_id = dashboard_id
    @metabase_site_url = metabase_site_url
    @metabase_secret_key = metabase_secret_key
  end

  def url
    token = ::JWT.encode(payload, metabase_secret_key)
    "#{metabase_site_url}/embed/dashboard/#{token}#bordered=false&titled=false"
  end

  private

  attr_reader :opco_id, :dashboard_id, :metabase_site_url, :metabase_secret_key

  def payload
    {
      resource: { dashboard: dashboard_id.to_i },
      params: { "opco_id" => [ opco_id ] },
      exp: 10.minutes.from_now.to_i
    }
  end
end
