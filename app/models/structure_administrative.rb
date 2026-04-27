class StructureAdministrative < Structure
  include AvecUsage

  before_validation :nettoie_champs_selon_usage

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

  private

  def nettoie_champs_selon_usage
    return if usage.blank?

    if evapro?
      self.parent_id = nil
    else
      self.opco_id = nil
    end
  end
end
