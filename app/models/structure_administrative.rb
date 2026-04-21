class StructureAdministrative < Structure
  include AvecUsage

  validates :usage, presence: true
  validates :opco, presence: true, if: :evapro?

  def metabase_dashboard
    53
  end

  def metabase_query_params
    { "structures" => structures_locales_filles.pluck(:id) }
  end

  def structures_locales_filles
    children.structures_locales
  end
end
