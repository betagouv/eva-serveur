class StructureOpco < Structure
  validates :opco, presence: true

  def metabase_dashboard
    ENV["METABASE_OPCO_DASHBOARD_ID"].to_i
  end

  def metabase_query_params
    { "opco_id" => [ opco_id ] }
  end
end
