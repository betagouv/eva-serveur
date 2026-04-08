module AvecUsage
  extend ActiveSupport::Concern

  USAGE_BENEFICIAIRES = "Eva: bénéficiaires".freeze
  USAGE_EVAPRO = "EVAPRO".freeze
  USAGE = [ USAGE_BENEFICIAIRES, USAGE_EVAPRO ].freeze

  included do
    validates :usage, inclusion: { in: USAGE }, allow_blank: true
  end

  def evapro?
    usage == USAGE_EVAPRO
  end
  alias_method :eva_entreprises?, :evapro?

  def eva_beneficiaires?
    usage == "Eva: bénéficiaires"
  end
end
