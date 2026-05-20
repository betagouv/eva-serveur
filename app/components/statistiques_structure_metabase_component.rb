class StatistiquesStructureMetabaseComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(structure:)
    @structure = structure
    @secret_key = ENV.fetch("METABASE_SECRET_KEY", nil)
  end

  def url
    payload = {
      resource: { dashboard: @structure.metabase_dashboard },
      params: @structure.metabase_query_params,
      exp: 10.minutes.from_now.to_i
    }
    token = ::JWT.encode payload, @secret_key

    "#{ENV.fetch('METABASE_SITE_URL', nil)}/embed/dashboard/#{token}#bordered=false&titled=false"
  end
end
